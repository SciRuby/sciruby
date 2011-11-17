# === SciRuby
#
# Ruby scientific visualization and computation.
#
# == Copyright Information
#
# Copyright (c) 2010 - 2011, Ruby Science Foundation
# All rights reserved.
#
# Please see LICENSE.txt for additional copyright notices.
#
# == Contributing
#
# By contributing source code to SciRuby, you agree to be bound by our Contributor
# Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# == sciruby.rb
#

require "rubygems"
require "bundler/setup"

module SciRuby
  VERSION = '0.1.3'
  DIR     = Pathname.new(__FILE__).realpath.dirname.to_s

  require File.join(::SciRuby::DIR, 'ext', 'string.rb')
  require File.join(::SciRuby::DIR, 'ext', 'csv.rb')

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

autoload(:Shoes, File.join(SciRuby::DIR, 'ext', 'shoes'))