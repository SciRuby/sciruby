require "rubyvis"
require "green_shoes"
require "rsvg2"

module SciRuby
  class Plotter
    def initialize script_or_handle
      update = false
      handle = begin
        if script_or_handle.is_a?(RSVG::Handle)
          script_or_handle
        else
          update = File.mtime(script_or_handle)
          SciRuby::Plotter.create_handle File.read(script_or_handle)
        end
      end

      Shoes.app :title => "Plotter - SciRuby", :width => handle.width+20, :height => handle.height+20 do
        puts app.win.inspect
        puts app.canvas.class.inspect
        strokewidth 1
        fill white
        r   = rect 10, 10, handle.width+2, handle.height+2
        img = image(:data => handle).tap { |i| i.move(11, 11) }

        # If a script was provided, watch it for updates
        every(2) do
          new_time = File.mtime(script_or_handle)
          unless new_time == update
            update  = new_time
            begin
              handle  = SciRuby::Plotter.create_handle(File.read(script_or_handle))
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

    class << self
      # Evaluate some code and draw an SVG.
      def create_handle script
        panel = eval script, binding, __FILE__, __LINE__
        panel.render
        RSVG::Handle.new_from_data(panel.to_svg).tap { |s| s.close }
      end
    end
  end
end

