module SciRuby
  module Data
    # R data module.
    class R < Base
      DIR = Pathname.new(__FILE__).realpath.dirname.to_s

      require "simpler"

      # Attempt to parse an R dataset through simpler. Works with most datasets (but not for table, dist, or array).
      #
      # Note that not all of these datasets have functions for converting directly to Statsample or SciRuby types. In
      # other words, parsing works, but it may not be as simple as calling to_dataset or to_h (yet).
      #
      # TODO: Add basic conversion functions like to_h, to_a, etc.
      #
      # == R datasets that don't work
      # * crimtab (table)
      # * eurodist (dist)
      # * HairEyeColor (table)
      # * iris3 (array)
      # * occupationalStatus (table)
      # * Titanic (table)
      # * UCBAdmissions (table)
      # * volcano (matrix): TODO: Handle non-named rows and columns in matrix
      #
      # TODO: rownames that are just counters need to be ignored in some cases, e.g., Puromycin
      #
      # == R datasets that work partially
      # * chickwts: doesn't know how to handle levels, but still loads them as strings.
      def dataset id
        begin
          r(id)
        rescue Simpler::RError => e
          raise DatasetNotFoundError.new(e)
        end
      end

      # TODO: Fix so that aggregate datasets, like state, are listed properly in search results.
      def search args={}
        parse_datasets_index(r.eval! { %q{library(help="datasets")} })
      end
      alias_method :datasets, :search

      # Alias for self.r.
      def r obj=nil; SciRuby::Data::R.r(obj); end

      
      class << self
        def in_dir &block
          SciRuby::Data.in_dir {  Dir.chdir('r') { yield } }
        end

        def in_man_dir &block
          in_dir {   Dir.chdir('man') { yield } }
        end

        # With an argument, this function attempts to read from R some variable (probably a built-in dataset).
        # Without an argument, this function gives access to the R console. See also: simpler by jtprince on github.
        def r obj=nil
          require "simpler"
          @@r ||= ::Simpler.new
          unless obj.nil?
            r_class = Base.class(obj)
            if r_class == 'numeric' || r_class == 'integer' || r_class == 'ordered' || r_class == 'factor' || r_class == 'character'
              return Vector.new(obj)
            elsif r_class == 'data.frame'
              return DataFrame.new(obj)
            elsif r_class == 'nfnGroupedData'
              return GroupedData.new(obj)
            elsif r_class == 'matrix'
              return RMatrix.new(obj)
            elsif r_class == 'ts'
              return TimeSeries.new(obj)
            elsif r_class == 'mts'
              return MultiTimeSeries.new(obj)
            elsif r_class == 'list'
              return List.new(obj).to_h
            else
              raise(NotImplementedError, "Don't know how to recognize class #{r_class} yet.")
            end
          end
          return @@r
        end
      end



      # Hacked together tex parser to extract useful information from .Rd R manual files. Unlikely to work on any other
      # TeX or LaTeX files.
      class Man < OpenStruct
        class << self
          def in_dir &block
            SciRuby::Data::R.in_man_dir { yield }
          end
        end

        def in_dir &block
          SciRuby::Data::R::Man.in_dir { yield }
        end


        def initialize dataset_id
          h = {}
          in_dir do
            raw = File.read("#{dataset_id}.Rd")
            entries = raw.split("\n\\") # this is a total hack
            entries.each do |entry|
              next if entry =~ /^%/
              command, content = entry.split('{', 2)
              h[command.underscore] = content.strip.gsub(/}$/, '').gsub(/\n$/, '')
            end
          end
          super(h)
        end
      end

    protected

      # Listing of datasets read directly from R.
      def parse_datasets_index raw
        h = {}
        mode = :pre

        last_key = nil

        raw.split("\n").each do |line|
          next if mode == :pre && line !~ /^Index\:/
          mode = :index
          next if line =~ /^Index\:/
          next if line.strip.empty?

          if line =~ /^ /
            h[last_key] = [h[last_key], line.strip].join(' ')
          else
            k, v        = line.split(' ', 2)
            last_key    = k.strip
            h[last_key] = v.strip
          end
        end

        h
      end
    end
  end
end

require File.join(SciRuby::Data::R::DIR, 'r', 'base.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'data_frame.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'time_series_base.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'time_series.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'multi_time_series.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'vector.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'r_matrix.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'grouped_data.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'list.rb')