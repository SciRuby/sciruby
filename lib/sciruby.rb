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

require "rubygems"
require "bundler/setup"

module SciRuby
  VERSION = '0.1.3'
  DIR     = Pathname.new(__FILE__).realpath.dirname.to_s

  class << self
    def plot script # &panel
      SciRuby::Plotter.new script
    end
  end

  autoload(:Plotter, File.join(DIR, 'sciruby', 'plotter'))
  autoload(:Editor, File.join(DIR, 'sciruby', 'editor'))
  autoload(:Recommend, File.join(DIR, 'sciruby', 'recommend'))
  autoload(:Validation, File.join(DIR, 'sciruby', 'validation'))
end

autoload(:Shoes, File.join(SciRuby::DIR, 'ext', 'shoes'))