require "green_shoes"

class Shoes
  class App
    def icon filename=nil
      filename.nil? ? win.icon : win.icon = filename
    end

    class << self
      def default_icon= filename
        Gtk::Window.set_default_icon(filename)
      end
    end
  end
end

module SciRuby
  ICON_PATH = File.join(DIR, '..', 'static', 'sciruby-icon.png')
end

Shoes::App.default_icon = SciRuby::ICON_PATH