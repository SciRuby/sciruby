# Copyright (c) 2010 - 2011, Ruby Science Foundation
# All rights reserved.
#
# Please see LICENSE.txt for additional copyright notices.
#
# By contributing source code to SciRuby, you agree to be bound by our Contributor
# Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# === plotter.rb
#

require "rsvg2"
require "rubyvis"
require "irb/ruby-lex"

module SciRuby
  class << self
    def Rubyvis
      ::Rubyvis
    end
  end

  class Plotter
    # Create a new plotter app.
    #
    # === Argument
    #
    # +script_or_handle+:: either a script filename which SciRuby::Plotter should
    #                      watch, or an RSVG::Handle which you have already created.
    #
    # === Examples
    #
    # Let's say you're in a Rails console and you want to use Plotter. You could do
    # something like this:
    #
    #     vis = Rubyvis::Panel.new do
    #       # your plot code here
    #     end
    #     vis.render
    #     svg_string = vis.to_svg
    #     svg_handle = RSVG::Handle.new_from_data svg_string
    #     SciRuby::Plotter.new svg_handle
    #
    # But you could also load a script as follows:
    #
    #    SciRuby::Plotter.new 'plot_xy.rb'
    #
    # If you take this route, you don't need to include a +render+ or a +to_svg+; these
    # are handled automatically when the script is evaluated.
    #
    # If you don't have your script saved, there's an additional option for static plots:
    #
    #    SciRuby::Plotter.new(SciRuby::Plotter.create_handle(:title => '(editor)', :raw_script => <<-ENDPLOT))
    #      Rubyvis::Panel.new do
    #        # plot code here
    #      end
    #    ENDPLOT
    #
    # Again, no +to_svg+ or +render+ is needed here.
    #
    def initialize script_or_handle
      update = false
      handle = begin
        if script_or_handle.is_a?(RSVG::Handle)
          script_or_handle
        else
          update = File.mtime(script_or_handle)
          handle = SciRuby::Plotter.create_handle :title => script_or_handle
        end
      end

      Shoes.app :title => "Plotter - SciRuby", :width => handle.width+20, :height => handle.height+20 do
        icon SciRuby::ICON_PATH
        strokewidth 1
        fill white
        r   = rect 10, 10, handle.width+2, handle.height+2
        img = image(:data => handle).tap { |i| i.move(11, 11) }

        keypress do |key|
          if key == 's'
            file = ask_save_file
            unless file.nil?
              begin
                SciRuby::Plotter.write_image(script_or_handle, file)
              rescue ArgumentError => e
                STDERR.puts e.inspect
                STDERR.puts e.backtrace
                alert "Unable to write format #{File.extname(file)}. Note that you can always save as an SVG.\n\n#{e.to_s}"
              end
            end
          end
        end

        # If a script was provided, watch it for updates
        every(2) do
          new_time = File.mtime(script_or_handle)
          unless new_time == update
            update  = new_time
            begin
              handle = SciRuby::Plotter.create_handle :title => script_or_handle
              img.real.clear # This may create a memory leak, but img.remove does not work.

              # Update window and rectangle size to accommodate new image, in case size has changed.
              app.resize handle.width+20, handle.height+20
              r.style    :width => handle.width+2,  :height => handle.height+2

              # Display new image.
              img     = image(:data => handle).tap { |i| i.move(11, 11) }
            rescue => e
              STDERR.puts e.backtrace
              alert "There appears to be an error in your plot code. Here's the trace:\n\n" + Plotter.clean_trace(e.backtrace, script_or_handle).join("\n"),
                    :title => "Rubyvis Error - SciRuby"
            end
          end
        end if update

      end
    end


    # A simple REPL without the P. Based roughly on IRB. Look on Wikipedia if you're not sure what a REPL is.
    class Interpreter
      def initialize filename, script = nil
        @filename = filename
        @bind     = binding
        @script = script.nil? ? File.new(filename, "r") : StringIO.new(script)
        @script.define_singleton_method(:encoding, lambda { external_encoding }) unless @script.respond_to?(:encoding)

        @scanner  = ::RubyLex.new
        @scanner.set_input @script
      end

      attr_reader :filename, :bind

      def eval_script
        vis = nil
        @scanner.each_top_level_statement do |line, line_number|
          line.untaint
          vis = eval(line, bind, filename, line_number)
        end
        vis = eval("vis", bind, __FILE__, __LINE__) unless vis.is_a?(::Rubyvis::Panel)
        vis.render()

        vis
      end
    end

    class << self
      # Render an SVG into an RSVG::Handle.
      #
      # This method used in preparation for drawing a watched script onto the Plotter window.
      #
      # It is also used occasionally to create a handle from an already-produced raw SVG file. Mostly this is in order
      # to save to other formats.
      #
      # === Arguments
      #
      # +:title+      ::  The script filename, or if +:raw_script+ is supplied, the title of the script (e.g., '(editor)')
      # +:raw_script+ ::  The raw script as a string, which you may want to supply if you're initializing Plotter inside
      #                   of a Rails or IRB console. Defaults to the contents of the file named in +:title+.
      # +:svg+        ::  The raw SVG string, if you've produced that already.
      #
      # You must supply at least +:svg+ OR +:title+.
      #
      def create_handle options = {}
        options = {
            :title => nil,
            :raw_script => nil,
            :svg    => nil
        }.merge(options)

        raise(ArgumentError, "Need at least :svg or :title for create_handle") if options[:title].nil? && options[:svg].nil?

        svg = options[:svg] || create_svg(options[:title], options[:raw_script])
        begin
          RSVG::Handle.new_from_data(svg).tap { |s| s.close }
        rescue RSVG::Error => e
          STDERR.puts "There appears to be a mysterious problem with the SVG output for your plot. Storing debug output in sciruby_debug.svg."
          STDERR.puts "Make sure your data() call is in the right place in your plot code."
          File.open("sciruby_debug.svg", "w") { |f| f.puts svg }
          raise e
        end
      end
      
      # Render an SVG, returning the file contents (not written). +title+ should be a filename, unless you supply a script
      # as a string for +raw_script+.
      def create_svg title, raw_script=nil
        vis = Interpreter.new(title, raw_script).eval_script
        svg = vis.to_svg
      end


      # Write image to a file. Format is chosen automatically based on +output_filename+.
      #
      # === Arguments
      #
      # +script_filename+::  The script to evaluate using +create_svg+
      # +output_filename+::  Name of the image file to write (needs to have an extension!)
      #
      def write_image script_filename, output_filename
        data = create_image_data(script_filename, File.extname(output_filename))
        File.open(output_filename, "w+") do |f|
          f.write(data)
        end
      end


      # Returns raw image data (a string) from either create_write_image or create_svg
      #
      # === Arguments
      #
      # +script_filename+::  The script to evaluate using +create_svg+
      # +output_extension+:: e.g., '.pdf' or '.svg', with or without the period
      #
      def create_image_data script_filename, output_extension
        # Normalize the output extension.
        output_extension.upcase!
        output_extension = output_extension.split('.').tap{ |ext| ext.shift }.join('.') if output_extension =~ /^\./

        if output_extension == 'SVG'
          create_svg script_filename
        else
          new_format = output_extension == 'PS' ? 'PS3' : output_extension
          create_image(script_filename, new_format).to_blob
        end
      end


      # Returns a Magick::Image that can be converted to a blob and then written directly to a file, based on the
      # +output_extension+ given. Uses RMagick to do the writing, so handles just about any format RMagick handles. For
      # a list supported by your machine, you can do:
      #
      #     require 'RMagick'
      #     Magick::formats
      #
      # Look for a 'w'. This means RMagick can write. If it has a - where the w should be, writing is not supported.
      #
      # Note about PostScript: For whatever reason, postscript quality is shitty in ImageMagick. This is a bug. You should
      # probably write to a PDF instead. If you need help writing to a PostScript, ask on the SciRuby Google Group, and
      # maybe we can resolve this bug together. =)
      #
      # === Arguments
      #
      # +script_filename+::  The script to evaluate using +create_svg+
      # +new_format+     ::  e.g., :PDF, :PS, :PS3, etc.
      #
      def create_image script_filename, new_format
        new_format = new_format.to_s
        begin
          require 'RMagick'

          format_support = Magick.formats[new_format]
          raise(ArgumentError, "RMagick cannot write format '#{new_format}'") if format_support.nil? || format_support[2] == '-'

          raw_svg = create_svg(script_filename)

          # Specify input parameters in the block. We're always going to convert *from* SVG, so that goes there.
          image = Magick::Image::from_blob(raw_svg) { self.format = 'SVG' }
          page  = image[0].page.dup # Get dimensions

          # Set write options.
          #   * format is based on the extension the user gives for the file. For most types, just use the extension.
          #     For postscript, you actually want PS3.
          #   * use-cropbox is for PDFs and postscripts, to tell it to use the cropbox instead of the mediabox. This
          #     improves the image quality by forcing it to use a size closer to that of the actual SVG. See also:
          #     https://github.com/SciRuby/sciruby/issues/15#issuecomment-2880761
          image[0].format = new_format

          if %w{PS PS2 PS3 PDF}.include?(new_format) # PDF/PS settings
            STDERR.puts "create_image: use-cropbox enabled"
            image[0]["use-cropbox"] = 'true'

            unless new_format == 'PDF'
              # This is a kludge. Not clear on why this is necessary, but otherwise quality is simply terrible.
              STDERR.puts "Warning: PostScript creation is wonky! See documentation on SciRuby::Plotter::create_image."
              STDERR.puts "create_image: setting density to 100x100; setting page dimensions"
              image[0].density = "100x100"
              image[0].page    = page
            end
          end

          image[0]
        rescue LoadError
          raise(ArgumentError, "RMagick not found; cannot write PDF")
        end
      end
      

      # Clean a trace so only the relevant information is included.
      def clean_trace bt, script_filename
        short_trace = []
        bt.each do |line|
          break unless line.include?(script_filename)
          short_trace << line
        end
        short_trace
      end
    end
  end
end

