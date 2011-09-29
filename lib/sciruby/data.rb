require "json"
require "net/http"
require "uri"
require "cgi"
require "ostruct"

module SciRuby
  module Data
    DIR = File.join(SciRuby::DIR, 'sciruby', 'data')

    def self.in_dir &block
      Dir.chdir(File.join(SciRuby::DIR, '..', 'data')) do
        yield
      end
    end

    # Really just a placeholder.
    class Base #:nodoc:
    end

    # Basic dataset type -- handles caching of datasets, that's about it.
    class Cacher < Base

      # Attempt to load a dataset. This is overridden for publicly-searchable datasets.
      # Basically it works as a fallback if a publicly-searchable database is unavailable for some reason, but we
      # may already have the data in the cache.
      def dataset source_id, module_name=nil
        module_name ||= self.class.to_s
        raw = cached_dataset(source_id, module_name)
        if raw.nil?
          raise(ArgumentError, "Dataset is not cached.")
        else
          match  = SciRuby::Config.data_source_dir(module_name, false) { SciRuby::Config.basename_exists?(source_id) }
          format = match.split('.').last.to_sym
          title  = SciRuby::Config.basename_for_dataset(source_id)
          parse_dataset(format, raw, title)
        end
      end
      
    protected

      # Attempt to get the dataset from the cache. This function is a little bit fragile for the following reason:
      # The +dataset+ function [eventually] allows for different +download_links+ of a dataset, which may be in different
      # formats. +cached_dataset+, however, guesses the format based on the format indicated for the first download link.
      #
      # TODO: Consider gzipping cached datasets.
      def cached_dataset source_id, module_name=nil
        module_name ||= self.class.to_s
        SciRuby::Config.for_dataset_basename(module_name, source_id) do |basename|
          filename = SciRuby::Config.basename_exists?(source_id)
          return nil unless filename
          File.read(filename)
        end
      end

      # Store a dataset locally. Use cached_dataset to retrieve.
      def cache_dataset source_id, raw_data, format
        SciRuby::Config.cache_dataset self.class.to_s, source_id, raw_data, format
      end

      # Parse and cache a dataset, using the appropriate interpreter.
      def parse_dataset format, raw, name
        begin
          case format
            when :csv
              CSV.parse(raw, :headers => true, :converters => :all).to_dataset.tap { |da| da.name = name }
            when :excel
              require "statsample"
              Statsample::Excel.parse(raw, :name => name)
          end
        rescue
          raise TypeError, "Format was not as expected; dataset may have moved"
        end
      end
    end


    # Base class for searching datasets. R dataset interpreter and PublicSearcherBase (and thus Guardian) are all derived
    # from this type.
    class Searcher < Cacher
      def initialize args={}
        @search_result = search(args)
      end
    end


    # Handles searching public datasets. Doesn't actually do it itself, but you can derive searchers from this -- e.g.,
    # Guardian.
    class PublicSearcher < Searcher
      FOUR_OH_FOUR_MESSAGE = '404'
      attr_reader :search_result

      # Search the site or database using some set of parameters.
      #
      # This function is the one that you should redefine if you want to require certain parameters, or if there are
      # parameter co-dependencies. Ultimately, you call `search_internal(params)`.
      #
      # == Example Arguments
      # * q: keywords
      # * facet_country: country code abbreviation to search
      # * facet_source_title: e.g., data from Australian government would be data.nsw.org.au
      def search args={}
        JSON.parse(search_internal(args))
      end

      # Download a dataset from a given link.
      def download_dataset link
        url = URI.parse link
        http_get(url.host, url.path)
      end

    protected
      # Like http_get, but gets the domain and path from the child searcher class.
      def search_internal params={} #:nodoc:
        domain = self.class.const_get(:QUERY_DOMAIN, true)
        path   = self.class.const_get(:QUERY_PATH, true)

        result = http_get(domain, path, params)

        if result.include?(self.class.const_get(:FOUR_OH_FOUR_MESSAGE, true))
          raise(IOError, "404 Not Found: domain='#{domain}'; path='#{path}'. Try again later.")
        end
        
        result
      end

      # Execute an HTTP get request with or without parameters.
      #
      # Adapted from: http://stackoverflow.com/questions/1252210/parametrized-get-request-in-ruby/1252305#1252305
      def http_get domain, path, params = {} #:nodoc:
        path_with_params = "#{path}?".concat(params.collect { |k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.join('&'))
        return Net::HTTP.get(domain, path_with_params) unless params.empty?
        Net::HTTP.get(domain, path)
      end
    end

    autoload(:R, File.join(DIR, 'r'))
    autoload(:Guardian, File.join(DIR, 'guardian'))
  end
end