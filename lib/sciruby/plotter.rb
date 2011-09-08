require "rubyvis"
require "green_shoes"

module SciRuby
  class Plotter
    DEFAULT_WIDTH   = 300
    DEFAULT_HEIGHT  = 400
    DEFAULT_SRC     = <<SRC
::Rubyvis::Panel.new do
  width 450
  height 450
  bar do
    data [1, 1.2, 1.7, 1.5, 0.7, 0.3]
    width 60
    height { |d| d * 240 }
    bottom(0)
    left { index * 75 }
  end
end
SRC

    def initialize

      s = Shoes.app(:title => "Plotter - SciRuby", :width => DEFAULT_WIDTH, :height => DEFAULT_HEIGHT) do
        stack do
          caption strong "enter rubyvis code:"

          unsaved  = false
          filename = nil

          code = code_box :text => DEFAULT_SRC,
                          :font => "Lucida Sans Typewriter", :width => width, :height => height - 100
          code.change do
            unsaved = true
          end

          flow do
            button "Save" do
              filename ||= ask_save_file
              unless filename.nil?
                unsaved = false
                File.open(filename, "w+") { |f| f.write code.text }
              end
            end

            button "Load" do
              if unsaved && confirm("Code in editor has not been saved. Changes will be lost. Are you sure you wish to load?")
                filename = ask_open_file
                unless filename.nil?
                  unsaved = false
                  code.text = File.read(filename)
                end
              end
            end

            button "Plot" do

              # Create the SVG
              svg = begin
                panel = eval code.text, binding, __FILE__, __LINE__
                panel.render
                panel.to_svg
              end
              svg_handle = RSVG::Handle.new_from_data(svg).tap { |s| s.close }

              window :title => "Plot View - SciRuby", :width => svg_handle.width+20, :height => svg_handle.height+20 do
                strokewidth 1
                fill white
                r = rect 10, 10, svg_handle.width+2, svg_handle.height+2
                image = image(:data => svg_handle).move(11, 11)
              end
            end
          end

          every(0.5) do
            code.style :width => self.width, :height => self.height - 100
          end

          # Not supported in Green Shoes.
          #finish do
          #  if unsaved && confirm("Unsaved changes. Do you want to save your work first?")
          #    filename ||= ask_save_file
          #    unless filename.nil?
          #      unsaved = false
          #      File.open(filename, "w+") { |f| f.write code.text }
          #    end
          #  end
          #end

        end
      end
    end
  end
end