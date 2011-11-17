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
# === shoes.rb
#

require "green_shoes"

class Shoes
  class App
    # This has been integrated into Green Shoes in the repo, but is not yet in the current gem.
    # Creates an edit_box for source code editing, using gtksourceview2.
    def code_box args={}
      require 'gtksourceview2'
      args = basic_attributes args

      args[:width]  = 400 if args[:width].zero?
      args[:height] = 300 if args[:height].zero?

      (change_proc = args[:change]; args.delete :change) if args[:change]
      sv = Gtk::SourceView.new
      sv.show_line_numbers = true
      sv.insert_spaces_instead_of_tabs = true
      sv.smart_home_end = Gtk::SourceView::SMART_HOME_END_ALWAYS
      sv.tab_width = 2
      sv.buffer.text = args[:text].to_s
      sv.buffer.language = Gtk::SourceLanguageManager.new.get_language('ruby')
      sv.buffer.highlight_syntax = true
      sv.modify_font(Pango::FontDescription.new(args[:font])) if args[:font]

      cb = Gtk::ScrolledWindow.new
      cb.set_size_request args[:width], args[:height]
      cb.set_policy Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC
      cb.set_shadow_type Gtk::SHADOW_IN
      cb.add sv

      sv.buffer.signal_connect "changed" do
        yield @_cb
      end if block_given?

      @canvas.put cb, args[:left], args[:top]

      cb.show_all
      args[:real], args[:app], args[:textview] = cb, self, sv
      @_cb = CodeBox.new(args).tap{|s| s.change &change_proc}
    end


    # Helper function for image() [with no name provided]. Currently only understands SVGs. Converts whatever it's given to
    # the format needed by Gtk::Image.new().
    #
    # Arguments:
    # * :data can be a string (e.g., for an SVG), an RSVG::Handle, a Gdk::Pixbuf, or even a Gtk::Image. If it can't tell which, it'll try
    #   calling the pixbuf() method on :data, or just returning it as is.
    # * :format, when it works, will specify the content-type of :data when that is not implicit in the class of :data. For example, if
    #   :data is a string, :format might be :svg.
    def image_handle args={}
      if args[:data].is_a?(String)
        raise(NotImplementedError, "Currently only RSVG::Handle is implemented.") if args.has_key?(:format) && args[:format] != :svg
        RSVG::Handle.new_from_data(args[:data]).tap{|s|s.close}.pixbuf
      elsif args[:data].is_a?(RSVG::Handle)
        args[:data].pixbuf
      elsif args[:data].is_a?(Gdk::Pixbuf) || args[:data].is_a?(Gtk::Image)
        args[:data]
      else
        # Unknown format. Try asking for a pixbuf, otherwise just assume it's already a pixbuf.
        args[:data].respond_to?(:pixbuf) ? args[:data].pixbuf : args[:data]
      end
    end


    # Improvement on Green Shoes' image function: accepts already-loaded images, such as those you might
    # create in-app. This has mostly been merged into green shoes, but that version is buggy.
    def image name, args={}
      # Handle case where no name is given -- typically, :data argument will be set.
      if name.is_a?(Hash)
        args = name
        name = nil
        raise(ArgumentError, ":data must be set if no name given") unless args.has_key?(:data)
      end

      args = basic_attributes args
      args[:full_width] = args[:full_height] = 0
      (click_proc = args[:click]; args.delete :click) if args[:click]

      if name.nil?
        img = Gtk::Image.new image_handle(args)

        args[:full_width], args[:full_height] = img.size_request if (!args[:width].zero? or !args[:height].zero?)
        downloading = false

      elsif name =~ /^(http|https):\/\//
        tmpname = File.join(Dir.tmpdir, "__green_shoes_#{Time.now.to_f}.png")
        d = download name, save: tmpname
        img = Gtk::Image.new File.join(DIR, '../static/downloading.png')
        downloading = true
      else
        img = Gtk::Image.new name
        downloading = false
      end

      if (!args[:width].zero? or !args[:height].zero?) and !downloading
        args[:full_width], args[:full_height] = imagesize(name) unless name.nil?
        args[:width] = args[:full_width] if args[:width].zero?
        args[:height] = args[:full_height] if args[:height].zero?
        img = Gtk::Image.new img.pixbuf.scale(args[:width], args[:height])
      end
      @canvas.put img, args[:left], args[:top]
      img.show_now
      @canvas.remove img if args[:hidden]
      args[:real], args[:app], args[:path] = img, self, name
      Image.new(args).tap do |s|
        @dics.push([s, d, tmpname]) if downloading
        s.click &click_proc if click_proc
      end
    end


    def icon filename=nil
      filename.nil? ? win.icon : win.icon = filename
    end

    class << self
      def default_icon= filename
        Gtk::Window.set_default_icon(filename)
      end
    end
  end

  class CodeBox < EditBox; end
end

module SciRuby
  ICON_PATH = File.join(DIR, '..', 'static', 'sciruby-icon.png')
end

Shoes::App.default_icon = SciRuby::ICON_PATH