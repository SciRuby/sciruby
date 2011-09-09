require "rubyvis"
require "green_shoes"
require "rsvg2"

module SciRuby
  class Plotter
    def initialize script_or_handle
      handle = begin
        if script_or_handle.is_a?(RSVG::Handle)
          script_or_handle
        else
          SciRuby::Plotter.create_handle File.read(script_or_handle)
        end
      end

      Shoes.app :title => "Plotter - SciRuby", :width => handle.width+20, :height => handle.height+20 do
        strokewidth 1
        fill white
        rect 10, 10, handle.width+2, handle.height+2
        image(:data => handle).move(11, 11)
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

