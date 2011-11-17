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
    # == Argument
    #
    # +script_or_handle+:: either a script filename which SciRuby::Plotter should
    #                      watch, or an RSVG::Handle which you have already created.
    #
    # == Examples
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
    #    SciRuby::Plotter.new(SciRuby::Plotter.create_handle('(editor)', <<-ENDPLOT))
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
          handle = SciRuby::Plotter.create_handle script_or_handle
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
                data = SciRuby::Plotter.create_write_data(script_or_handle, File.extname(file))
                File.open(file, "w+") do |f|
                  f.write(data)
                end
              rescue ArgumentError => e
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
              handle = SciRuby::Plotter.create_handle script_or_handle
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
      # Render an SVG into memory from the watched file / editor, returning a handle.
      def create_handle filename, script=nil
        svg = create_svg filename, script
        begin
          RSVG::Handle.new_from_data(svg).tap { |s| s.close }
        rescue RSVG::Error => e
          STDERR.puts "There appears to be a mysterious problem with the SVG output for your plot. Storing debug output in debug.svg."
          STDERR.puts "Make sure your data() call is in the right place."
          File.open("debug.svg", "w") { |f| f.puts svg }
          raise e
        end
      end
      
      # Render an SVG, returning the file contents (not written).
      def create_svg filename, script=nil
        vis = Interpreter.new(filename, script).eval_script
        svg = vis.to_svg
      end

      # Returns raw data that can be written directly to a file, based on the +output_extension+ given. Uses RMagick to
      # do the writing, so handles just about any format RMagick handles. For a list supported by your machine, you can
      # do:
      #
      #     require 'RMagick'
      #     Magick::formats
      #
      # Look for a 'w'. This means RMagick can write. If it has a - where the w should be, writing is not supported.
      #
      # = Arguments
      #
      # +script_filename+::  The script to evaluate using +create_svg+
      # +output_extension+:: e.g., '.pdf' or '.svg', with or without the period
      # +width+::            width of the image to be created
      # +height+::           height of the image to be created
      #
      def create_write_data script_filename, output_extension
        # Normalize the output extension.
        output_extension.upcase!
        output_extension = output_extension.split('.').tap{ |ext| ext.shift }.join('.') if output_extension =~ /^\./

        if output_extension == 'SVG'
          create_svg script_filename
        else
          begin
            require 'RMagick'

            format_support = Magick.formats[output_extension]
            raise(ArgumentError, "RMagick cannot write format '#{output_extension}'") if format_support.nil? || format_support[2] == '-'

            image = Magick::Image::from_blob(create_svg(script_filename)) { self.format = 'SVG' }
            image[0].format = output_extension
            image[0].to_blob

          rescue LoadError
            raise(ArgumentError, "RMagick not found; cannot write PDF")
          end
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

