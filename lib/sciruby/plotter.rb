require "rubyvis"
require "green_shoes"
require "rsvg2"

module SciRuby
  class << self
    def Rubyvis
      ::Rubyvis
    end
  end

  class Plotter

    def initialize script_or_handle
      update = false
      handle = begin
        if script_or_handle.is_a?(RSVG::Handle)
          script_or_handle
        else
          update = File.mtime(script_or_handle)
          SciRuby::Plotter.create_handle File.read(script_or_handle), script_or_handle
        end
      end

      Shoes.app :title => "Plotter - SciRuby", :width => handle.width+20, :height => handle.height+20 do
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
              handle  = SciRuby::Plotter.create_handle(File.read(script_or_handle), script_or_handle)
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
      def create_handle script, filename=nil
        filename ||= '(editor)'
        bind = TOPLEVEL_BINDING
        eval 'require "rubyvis"', bind, __FILE__, __LINE__
        file_line_number = 0
        vis = nil
        script.each_line do |line|
          file_line_number += 1
          vis = eval script, bind, filename, file_line_number
        end

        vis = eval("vis", bind, __FILE__, __LINE__) unless vis.is_a?(::Rubyvis::Panel)
        vis.render()

        RSVG::Handle.new_from_data(vis.to_svg).tap { |s| s.close }
      end
    end
  end
end

