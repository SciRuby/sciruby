require "green_shoes"
require "gtksourceview2"
require "rsvg2"
require "rubyvis"


class Shoes
  class App

    # Display an already-loaded image. Note that neither :left nor :top works for image and buffered_image. This appears
    # to be a green shoes problem.
    def buffered_image content, args={}
      args = basic_attributes args
      args[:full_width] = args[:full_height] = 0
      (click_proc = args[:click]; args.delete :click) if args[:click]

      img = Gtk::Image.new(begin
        if content.is_a?(String)
          RSVG::Handle.new_from_data(content).tap { |s| s.close }
        elsif content.is_a?(RSVG::Handle)
          content
        else
          raise(ArgumentError, "buffered_image needs an SVG string or an RSVG handle")
        end
      end.pixbuf)

      @canvas.put img, args[:left], args[:top]
      img.show_now
      @canvas.remove img if args[:hidden]

      args[:real], args[:app] = img, self
      Image.new(args).tap do |s|
        s.click &click_proc if click_proc
      end
    end


    # Edit box for source code
    def code_box args={}
      args = basic_attributes args

      args[:font] ||= "Lucida Sans Typewriter"
      args[:width]  = 200 if args[:width].zero?
      args[:height] = 108 if args[:height].zero?

      (change_proc = args[:change]; args.delete :change) if args[:change]
      sv = Gtk::SourceView.new
      sv.wrap_mode = Gtk::TextTag::WRAP_NONE
      sv.insert_spaces_instead_of_tabs = true
      sv.auto_indent = true
      sv.smart_home_end = Gtk::SourceView::SMART_HOME_END_ALWAYS
      sv.tab_width = 2
      sv.buffer.text = args[:text].to_s
      sv.buffer.language = CodeBox::RUBY_LANG
      sv.modify_font(Pango::FontDescription.new(args[:font])) if args[:font]

      eb = Gtk::ScrolledWindow.new
      eb.set_size_request args[:width], args[:height]
      eb.set_policy Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC
      eb.set_shadow_type Gtk::SHADOW_IN
      eb.add sv

      sv.buffer.signal_connect "changed" do
        yield @_eb
      end if block_given?

      @canvas.put eb, args[:left], args[:top]

      eb.show_all
      args[:real], args[:app], args[:textview] = eb, self, sv
      @_eb = CodeBox.new(args).tap{|s| s.change &change_proc}
    end
  end

  class CodeBox < EditBox
    RUBY_LANG = Gtk::SourceLanguageManager.new.get_language('ruby')
  end
end


module SciRuby
  class Plotter
    DEFAULT_WIDTH   = 300
    DEFAULT_HEIGHT  = 400
    DEFAULT_SRC     = <<SRC
::Rubyvis::Panel.new do
  width 150
  height 150
  bar do
    data [1, 1.2, 1.7, 1.5, 0.7, 0.3]
    width 20
    height { |d| d * 80 }
    bottom(0)
    left { index * 25 }
  end
end
SRC

    def initialize

      Shoes.app(:title => "Plotter - SciRuby", :width => DEFAULT_WIDTH, :height => DEFAULT_HEIGHT) do
        @s = stack do
          caption strong "enter rubyvis code:"
          code = code_box :text => DEFAULT_SRC, :font => "Lucida Sans Typewriter", :width => self.width, :height => self.height - 100

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
              image = buffered_image(svg_handle).move(11, 11)

              every(0.5) do
                r.style :width => self.width - 20, :height => self.height - 18
              end
            end
          end

          every(0.5) do
            code.style :width => self.width, :height => self.height - 100
          end

        end
      end
    end
  end
end