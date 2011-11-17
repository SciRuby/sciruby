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
# === guardian.rb
#

module SciRuby
  module Data
    
    # World Government Data from the Guardian.
    class Guardian < PublicSearcher
      QUERY_DOMAIN = %q{www.guardian.co.uk}
      QUERY_PATH   = %q{/world-government-data/search.json}
      FOUR_OH_FOUR_MESSAGE = '404 Page not found'
      ALLOWED_FORMATS = [:csv, :excel]

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
        #args[:facet_format] ||= :csv
        #@require_format ||= args[:facet_format] # This should be removed when we can interpret other formats.

        @search_result = search(args)
      end

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

            unless ALLOWED_FORMATS.include?(link_info.format)
              pos += 1
              next # Format is incorrect.
            end

            # Format appears to be correct, prior to actually downloading. Proceed.

            # Attempt to read the cached one first, and if that fails, try downloading.
            raw = cached_dataset(source_id) || download_dataset(link_info.link)
            
            begin
              ds  = parse_dataset link_info.format, raw, datasets[source_id].title
              cache_dataset(source_id, raw, link_info.format)
            rescue TypeError => e
              if pos == datasets[source_id].download_links.size - 1
                raise DatasetNotFoundError.new(e)
              end
            ensure
              pos += 1
            end

            return ds unless ds.nil?

          end
        end
      end

    end
  end
end
