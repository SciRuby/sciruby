require "json"
require "net/http"
require "uri"
require "cgi"
require "ostruct"

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
        return Net::HTTP.get(domain, path_with_params) unless params.empty?
        Net::HTTP.get(domain, path)
      end
    end

    # World Government Data from the Guardian.
    class Guardian < SearcherBase
      QUERY_DOMAIN = %q{www.guardian.co.uk}
      QUERY_PATH   = %q{/world-government-data/search.json}

      class DatasetInfo < ::OpenStruct
        def initialize h
          super h
          self.download_links.each_index do |i|
            self.download_links[i] = ::OpenStruct.new(self.download_links[i])
          end
        end
      end


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
        @require_format ||= args[:facet_format] # This should be removed when we can interpret other formats.

        super args
      end

      attr_reader :search_result

      # Return dataset meta-data found in the search, hashed by source_id. So, do datasets.keys if you want a list of
      # source_ids.
      def datasets
        @datasets ||= begin
          h = {}
          search_result["results"].each do |res|
            h[res['source_id']] = DatasetInfo.new(res)
          end
          h
        end
      end


      # After a call to dataset(source_id), what is the content that was downloaded from a given +link+?
      def raw_dataset source_id, link
        @raw_dataset ||= {}
        @raw_dataset[source_id] ||= {}
        @raw_dataset[source_id][link] ||= begin
          url = URI.parse link
          http_get_internal(url.host, url.path)
        end
      end

      # After a call to dataset(source_id), from what links did we download?
      def raw_dataset_links_cached source_id=nil
        return @raw_dataset if source_id.nil?
        @raw_dataset[source_id].keys
      end

      # Download a specific dataset by +source_id+ and cache it in the searcher. Returns a Statsample::Dataset.
      #
      # If this raises an exception, you can try this:
      #
      #     links = raw_dataset_links_cached(source_id)
      #
      # And then for each of +links+, do `raw_dataset(source_id, link)` to see what the actual downloaded data was.
      # This is good for debugging -- e.g., did the page move? or is there something wrong with Ruby's CSV interpreter?
      # Or is it in some other format altogether?
      #
      # Right now, this function only handles CSV. TODO: Add more format handlers!
      def dataset source_id
        @dataset ||= {}
        @dataset[source_id] ||= begin # Datasets are stored by source ID
          pos = 0
          datasets[source_id].download_links.each do |link_info|

            unless link_info.format == @require_format.to_s
              pos += 1
              next # Format is incorrect.
            end

            # Format appears to be correct, prior to actually downloading. Proceed.
            d = nil
            exception_raised = false

            raw = raw_dataset(source_id, link_info.link)

            begin
              d = CSV.parse(raw, :headers => true, :converters => :all).to_dataset
              d.name = datasets[source_id].title
            rescue CSV::MalformedCSVError => e
              exception_raised = true
              raise(TypeError, "Malformed CSV; dataset has probably moved") if pos == datasets[source_id].download_links.size - 1
            ensure
              pos += 1
            end
            return d unless d.nil?

            raise(TypeError, "All dataset sources returned malformed CSV data; dataset has probably moved") if exception_raised
            raise(NameError, "Couldn't find any dataset sources in the correct format (CSV)")
          end
        end
      end
    end

  end
end