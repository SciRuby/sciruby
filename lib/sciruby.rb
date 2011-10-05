# = sciruby.rb -
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
require "./lib/ext/string"

module SciRuby
  VERSION = '0.1.3'
  DIR     = Pathname.new(__FILE__).realpath.dirname.to_s

  class << self
    def plot script
      SciRuby::Plotter.new script
    end

    def integrate *args, &block
      require "integration"
      ::Integration.integrate(*args, &block)
    end

    # Produce a list of datasets that can be loaded using the +dataset+ method
    def dataset_search database, args = {}
      "SciRuby::Data::#{database.to_s.camelize}".constantize.new(args).datasets.keys
    end

    # Load a dataset from a specific database. For a list of datasets, use `dataset_search(:guardian)`, for example.
    def dataset database, source_id
      begin
        "SciRuby::Data::#{database.to_s.camelize}".constantize.new.dataset(source_id)
      rescue DatabaseUnavailableError => e
        warn "Database appears to be unavailable. Attempting to use cached version."
        SciRuby::Data::Cacher.new.dataset(source_id, database)
      end
    end

    # Shorthand for SciRuby::Analysis.store(*args, &block)
    def analyze *args, &block
      SciRuby::Analysis.store(*args, &block)
    end
  end

  autoload(:Analysis, File.join(DIR, 'sciruby', 'analysis'))
  autoload(:Config, File.join(DIR, 'sciruby', 'config'))
  autoload(:Editor, File.join(DIR, 'sciruby', 'editor'))
  autoload(:Plotter, File.join(DIR, 'sciruby', 'plotter'))
  autoload(:Recommend, File.join(DIR, 'sciruby', 'recommend'))
  autoload(:Validation, File.join(DIR, 'sciruby', 'validation'))
  autoload(:Data, File.join(DIR, 'sciruby', 'data'))
end

autoload(:Statsample, File.join(SciRuby::DIR, 'ext', 'statsample'))
autoload(:Shoes, File.join(SciRuby::DIR, 'ext', 'shoes'))
autoload(:CSV, File.join(SciRuby::DIR, 'ext', 'csv'))
