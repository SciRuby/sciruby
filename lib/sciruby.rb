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
# as published by the Free Software Foundation; either version 2
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
  VERSION = '0.1.1'

  autoload(:Recommend, 'sciruby/recommend')
  autoload(:Validation, 'sciruby/validation')
end
