require "rubyvis"
require "rsvg2"
require "gtk2"
require "gtksourceview2"

module SciRuby
  class Editor
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
      Shoes.app(:title => "Plot Editor - SciRuby", :width => DEFAULT_WIDTH, :height => DEFAULT_HEIGHT) do
        icon SciRuby::ICON_PATH
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
              SciRuby::Plotter.new(SciRuby::Plotter.create_handle('(editor)', code.text))
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
