module SciRuby
  module Data
    # R data module.
    class R < SearcherBase
      DIR = Pathname.new(__FILE__).realpath.dirname.to_s

      require "simpler"

      class << self
        def in_dir &block
          SciRuby::Data.in_dir {  Dir.chdir('r') { yield } }
        end
        
        def in_man_dir &block
          in_dir {   Dir.chdir('man') { yield } }
        end

        def in_data_dir &block
          in_dir {   Dir.chdir('data') { yield } }
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

      def in_data_dir &block; SciRuby::Data::R.in_data_dir { yield } ; end

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
        in_data_dir do
          if File.exist? "#{id}.tab"
            return Tab.new("#{id}.tab").to_dataset
          end
        end

        raise(NotImplementedError, "Need to handle non-tab format data")
      end


      def search args={}
        parse_datasets_index(r.eval! { %q{library(help="datasets")} })
      end


      # Represents a .tab file in R. Only handles reading. e.g., morley.tab in R data. This class is deprecated by r(obj)
      class Tab
        def initialize filename
          @contents = filename.include?("\n") ? filename : File.read(filename)
        end

        def to_dataset
          parse_tab.to_dataset
        end

        def parse_tab
          self.class.parse_tab @contents
        end

        class << self
          # Read an R .tab file.
          def parse_tab raw
            require "statsample"

            lines = raw.split("\n")
            first_line = lines.shift
            fields = first_line.split
            h = Hash.new { |h,k| h[k] = [] }
            lines.each do |line|
              entries = line.split

              # Forgot to include the blank column header in fields
              fields.unshift(fallback_header(fields)) if entries.size > fields.size && first_line =~ /^ /

              entries.each_index do |i|
                h[fields[i]] << entries[i]
              end
            end

            # Need to convert from string to the correct data type.
            h.each_pair do |key, values|
              new_values = []

              level = :to_i
              # TODO: Make this less hackish. Find a way to handle strings too. Maybe use whatever CSV for the :converters param.
              values.each do |val|
                level = :to_f if val =~ /\./ || val =~ /e/ || val =~ /E/
              end
              values.each do |val|
                new_values << val.send(level)
              end
              h[key] = new_values.to_scale
            end

            h
          end
        protected
          # Header to fall back on for a vector of rownames that have no column name.
          def fallback_header(fields)
            return 'row.names' unless fields.include?('row.names')
            return 'rownames' unless fields.include?('rownames')
            return 'rnames' unless fields.include?('rnames')
            return 'id' unless fields.include?('id')
            raise(NotImplementedError, "You have a column of row names with no name in your table, and all three of the fallback headers are taken (row.names, rownames, rnames, id). This is weird.")
          end
        end

      end

      # Hacked together tex parser to extract useful information from .Rd R manual files. Unlikely to work on any other
      # TeX or LaTeX files.
      class Man < OpenStruct
        def in_dir &block
          SciRuby::Data::R.in_man_dir { yield }
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

STDERR.puts File.expand_path(__FILE__)

require File.join(SciRuby::Data::R::DIR, 'r', 'base.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'data_frame.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'time_series_base.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'time_series.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'multi_time_series.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'vector.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'r_matrix.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'grouped_data.rb')
require File.join(SciRuby::Data::R::DIR, 'r', 'list.rb')