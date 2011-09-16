require "rsvg2"
require "rubyvis"
require "green_shoes"
require "irb/ruby-lex"

module SciRuby
  class << self
    def Rubyvis
      ::Rubyvis
    end
  end

  class Plotter
    # Create a new plotter app.
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
        strokewidth 1
        fill white
        r   = rect 10, 10, handle.width+2, handle.height+2
        img = image(nil, :data => handle).tap { |i| i.move(11, 11) }

        # If a script was provided, watch it for updates
        every(2) do
          new_time = File.mtime(script_or_handle)
          unless new_time == update
            update  = new_time
            begin
              #handle  = SciRuby::Plotter.create_handle(File.read(script_or_handle), script_or_handle)
              handle = SciRuby::Plotter.create_handle script_or_handle
              img.real.clear # This may create a memory leak, but img.remove does not work.

              # Update window and rectangle size to accommodate new image, in case size has changed.
              #app.resize handle.width+20, handle.height+20
              app.resize handle.width+20, handle.height+20
              r.style    :width => handle.width+2,  :height => handle.height+2

              # Display new image.
              img     = image(:data => handle).tap { |i| i.move(11, 11) }
            rescue => e
              alert "There appears to be an error in your plot code. Here's the trace:\n\n" + e.backtrace.join("\n"),
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
      # Render an SVG into memory from the watched file / editor.
      def create_handle filename, script=nil
        vis = Interpreter.new(filename, script).eval_script
        RSVG::Handle.new_from_data(vis.to_svg).tap { |s| s.close }
      end
    end
  end
end

