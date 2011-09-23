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

    # Basic dataset type -- handles caching of datasets, that's about it.
    class Base
      # Attempt to get the dataset from the cache. This function is a little bit fragile for the following reason:
      # The +dataset+ function [eventually] allows for different +download_links+ of a dataset, which may be in different
      # formats. +cached_dataset+, however, guesses the format based on the format indicated for the first download link.
      #
      # TODO: Fix this, probably by adding a file extension to cached datasets, and using that to determine the interpreter.
      # TODO: Consider gzipping cached datasets.
      def cached_dataset source_id
        SciRuby::Config.for_dataset self.class.to_s, source_id do |filename|
          return nil unless File.exists?(filename)
          return File.read(filename)
        end
      end

      # Store a dataset locally. Use cached_dataset to retrieve.
      def cache_dataset source_id, raw_data
        SciRuby::Config.cache_dataset self.class.to_s, source_id, raw_data
      end
    end


    # Handles searching public datasets. Doesn't actually do it itself, but you can derive searchers from this -- e.g.,
    # Guardian.
    class SearcherBase < Base
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

      def initialize args={}
        @search_result = search(args)
      end

      # Download a dataset from a given link.
      def download_dataset link
        url = URI.parse link
        http_get(url.host, url.path)
      end

    protected
      # Like http_get, but gets the domain and path from the child searcher class.
      def search_internal params={} #:nodoc:
        http_get(self.class.const_get(:QUERY_DOMAIN, true), self.class.const_get(:QUERY_PATH, true), params)
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