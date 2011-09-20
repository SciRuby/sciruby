require "json"
require "net/http"
require "uri"
require "cgi"
require "ostruct"
require "csv"

module SciRuby
  module Data

    class SearcherBase

      def initialize args={}
        @search_result = search(args)
      end

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
        JSON.parse(http_get(args))
      end

    protected
      # Like http_get_basic, but gets the domain and path from the child searcher class.
      def http_get params={} #:nodoc:
        http_get_internal(self.class.const_get(:QUERY_DOMAIN, true), self.class.const_get(:QUERY_PATH, true), params)
      end

      # Execute an HTTP get request with or without parameters.
      #
      # Adapted from: http://stackoverflow.com/questions/1252210/parametrized-get-request-in-ruby/1252305#1252305
      def http_get_internal domain, path, params = {} #:nodoc:
        path_with_params = "#{path}?".concat(params.collect { |k,v| "#{k.to_s}=#{CGI::escape(v.to_s)}"}.join('&'))
        STDERR.puts [domain, path_with_params].join("\t")
        return Net::HTTP.get(domain, path_with_params) unless params.empty?
        Net::HTTP.get(domain, path)
      end
    end

    # World Government Data from the Guardian.
    class Guardian < SearcherBase
      QUERY_DOMAIN = %q{www.guardian.co.uk}
      QUERY_PATH   = %q{/world-government-data/search.json}

      # Search the site or database using some set of parameters.
      #
      # This function is the one that you should redefine if you want to require certain parameters, or if there are
      # parameter co-dependencies. Ultimately, you call `search_internal(params)`.
      #
      # == Arguments
      # * q: keywords (default: '', if no other parameters are supplied)
      # * facet_country: country code abbreviation to search
      # * facet_source_title: e.g., data from Australian government would be data.nsw.org.au
      # * facet_format: e.g., csv, excel, xml, shapefile, kml
      def initialize args={}
        args[:facet_format] ||= :csv
        @require_format ||= args[:facet_format]
        super args
      end

      attr_reader :search_result

      # Get a hash of dataset information by source_id
      def dataset_info
        @dataset_info ||= begin # Datasets are stored by source ID
          h = {}
          search_result["results"].each do |result|
            h[result["source_id"]] = result
          end
          h
        end
      end

      def dataset source_id=nil
        @dataset ||= {}
        @dataset[source_id] ||= begin # Datasets are stored by source ID
          dataset_info[source_id]["download_links"].each do |link_info|
            next unless link_info["format"] == @require_format.to_s
            url = URI.parse(link_info["link"])
            return CSV.parse(http_get_internal(url.host, url.path))
          end
        end
      end
    end

  end
end