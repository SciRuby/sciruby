# = sci_ruby.rb -
# SciRuby - Ruby scientific visualization and computation.
#
# Copyright (C) 2011  SciRuby Development Team
#  * John O. Woods
#  * John T. Prince
#  * Claudio Bustos
#  * others
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# Specific notices will be placed where they are appropriate.
#

module SciRuby
  VERSION = '0.1.2'

  class << self
    def plot svg # &panel
      svg = File.read(svg)
      #vis = yield(panel)
      #vis.render
      #svg = vis.to_svg
      img = Magick::Image.from_blob(svg).first
      scaled_img = img.scale(250, 250)
      Shoes.app(:width => 250, :height => 250) do
        image scaled_img
      end
    end
  end

  autoload(:Plotter, 'sciruby/plotter')
  autoload(:Recommend, 'sciruby/recommend')
  autoload(:Validation, 'sciruby/validation')
end
