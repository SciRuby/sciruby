module SciRuby
  module Data
    # R data module.
    class R < SearcherBase
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
        #
        # == R datasets that don't work
        # * ChickWeight (nfnGroupedData)
        # * CO2 (nfnGroupedData)
        # * crimtab (table)
        # * DNase (nfnGroupedData)
        # * eurodist (dist)
        # * HairEyeColor (table)
        # * Harman*.cor (list)
        # * Harman*.cor$cov (matrix)
        # * Indometh (nfnGroupedData)
        # * infert TODO: Fix regular expressions.
        # * iris3 (array)
        # * islands TODO: Fix regular expressions.
        # * LifeCycleSavings TODO: Fix regular expressions.
        # * Loblolly (nfnGroupedData)
        # * mtcars TODO: Fix regular expressions.
        # * occupationalStatus (table)
        # * Orange (nfnGroupedData)
        # * precip TODO: Fix regular expressions.
        # * state.name, state.division, state.region TODO: Fix regular expressions.
        # * state.center (list)
        # * state.x77 (matrix)
        # * swiss (though this works if loaded as a .tab instead)
        # * Theoph (nfnGroupedData)
        # * Titanic (table)
        # * UCBAdmissions (table)
        # * USArrests TODO: Fix regular expressions.
        # * USPersonalExpenditure (matrix)
        # * VADeaths (matrix)
        # * volcano (matrix)
        # * WorldPhones (matrix)
        #
        # Note that the TODO listings for regular expressions above mainly refer to quoted names containing spaces.
        # 
        # TODO: rownames that are just counters need to be ignored in some cases, e.g., Puromycin
        #
        # == R datasets that work partially
        # * chickwts: doesn't know how to handle levels, but still loads them as strings.
        def r obj=nil
          require "simpler"
          @@r ||= ::Simpler.new
          unless obj.nil?
            r_class = Raw.class(obj)
            if r_class == 'numeric' || r_class == 'integer'
              return RNumeric.new(obj)
            elsif r_class == 'ordered' || r_class == 'factor' || r_class == 'character'
              return ROrdered.new(obj)
            elsif r_class == 'data.frame'
              return RDataFrame.new(obj)
            elsif r_class == 'ts'
              return RTimeSeries.new(obj)
            elsif r_class == 'mts'
              return RMultiTimeSeries.new(obj)
            #elsif r_class == 'integer'
            #  raise(NotImplementedError, "Can't handle integers: #{obj}")
            else
              raise(NotImplementedError, "Don't know how to recognize class #{r_class} yet.")
            end
          end
          return @@r
        end
      end

      def in_data_dir &block; SciRuby::Data::R.in_data_dir { yield } ; end


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


      # Parses datasets from R directly.
      class Raw
        FLOAT_RE = /([.eE])/

        require "simpler"
        
        def initialize id
          @rob  = id # R object name

          assign_properties # Read as many properties as possible from R
        end

        def self.class obj
          Raw.new(obj).send :read_class
        end

        attr_reader :rob
        alias_method :rname, :rob

      protected
        def assign_properties; end

        def r obj=nil
          SciRuby::Data::R.r(obj)
        end

        def float_re
          SciRuby::Data::R::Raw::FLOAT_RE
        end

        def call_function fn=nil
          STDERR.puts "Call function: #{fn.to_s}"
          fn.nil? ? r.eval! { rob } : r.eval! { "#{fn.to_s}(#{rob})" }
        end

        def call_property prop
          r.eval! { "#{rob}$'#{prop.to_s}'"}
        end

        def read_class fn=:class
          read_single_token(fn).split(%q{"})[1]
        end

        def read_single_line fn=nil
          line = call_function fn
          STDERR.puts "rsl Got back: #{line}"
          line.split.tap{ |s| s.shift }
        end

        def read_single_token fn=nil
          line = call_function fn
          STDERR.puts "rst Got back: #{line}"
          line.split.tap{ |s| s.shift }.first
        end

        # Read multiple lines from a function call. You can also pass in a block if you want to ask for a property instead
        # of a function call, e.g.,
        #     read_multiple_lines { call_property('height') }
        def read_multiple_lines fn=nil
          lines = block_given? ? yield : call_function(fn)
          STDERR.puts "rml Got back:\n#{lines}"

          lines = lines.split("\n")

          return nil if lines.first =~ /^NULL/
          return lines.map { |line| line.split.tap { |s| s.shift } }.flatten if lines.first =~ /^ *\[/


          # If we get this far, it's a c() with named rows. Obnoxious!
          index = 0
          keys    = []
          entries = []

          lines.map do |line|
            val = begin
              if line =~ /^Levels/
                []
              elsif index % 2 == 0
                keys.concat line.split
              else
                entries.concat line.split
              end
            end
            index += 1
            val
          end

          h = {}
          keys.each_index do |i|
            h[keys[i]] = entries[i]
          end
          h
        end

        def read_row_names fn='rownames'
          attempt = read_multiple_lines(fn) # may return nil if no rownames found.
          attempt.nil? ? [] : attempt.map { |entry| entry.split('"')[1] }
        end

        def read_col_names fn='colnames'
          read_row_names fn
        end

        def read_columns fields
          columns = {}
          fields.each do |field|
            columns_for_field = SciRuby::Data::R.r("#{rob}[,'#{field.to_s}']")
            columns[field] = columns_for_field.is_a?(ROrdered) || columns_for_field.is_a?(RTimeSeries) ? columns_for_field : columns_for_field.to_a
          end
          columns
        end

      end


      
      class RDataFrame < Raw
        attr_reader :row_names, :columns

        def col_names
          columns.keys
        end

        def levels col_name
          columns[col_name].levels
        end

      protected

        def assign_properties
          @row_names = read_row_names
          col_names  = read_col_names
          @columns   = read_columns(col_names)
        end

      end


      class RNumeric < Raw
        attr_reader :data
        alias_method :to_a, :data

      protected
        def assign_properties
          @data = read_array_data
        end

        def read_array_data fn=nil
          entries = read_multiple_lines fn
          return nil if entries.nil?

          access = entries.is_a?(Array) ? :each_index : :each_key
          mode = :unclear

          entries.send access do |j|
            if entries[j] == 'NaN'
              entries[j] = 0.0/0.0 # NaN
            elsif entries[j] == '<NA>' || entries[j] == 'NA'
              entries[j] = nil
            elsif entries[j] == 'Inf'
              entries[j]  = 1.0/0.0 # Infinity
            elsif mode == :unclear
              if entries[j] == 'TRUE'
                entries[j] = true
              elsif entries[j] == 'FALSE'
                entries[j] = false
              else
                if entries[j] =~ /[A-DF-Za-df-z\+\/]/ || entries[j] =~ /^[0-9]+-[0-9]*$/
                  mode = :to_s
                elsif entries[j] =~ /^[0-9]+$/
                  mode = :to_i
                else
                  mode = :to_f
                end
                entries[j] = entries[j].send(mode)
              end
            else
              entries[j] = entries[j].send(mode)
            end
          end

          entries
        end
      end

      class ROrdered < RNumeric
        def to_h
          {:data => @data, :levels => @levels}
        end

      protected
        def assign_properties
          @data = read_array_data
          levels = read_array_data(:levels)

          @levels = levels.map do |s|
            s =~ /^\"/ && s =~ /\"$/ ? s.split('"')[1] : s
          end unless levels.nil?
        end
      end

      # classes 'mts' and 'ts' in R; not instantiated directly. Use RTimeSeries or RMultiTimeSeries.
      class RTimeSeriesBase < Raw
        attr_reader :start, :end, :frequency, :delta_t

      protected

        def assign_properties
          @start      = read_time(:start)
          @end        = read_time(:end)
          @frequency  = read_frequency

          # in R, the user supplies either frequency or delta t, but not both. frequency is always an integer (if I remember correctly)
          @delta_t    = @frequency.is_a?(Fixnum) && @frequency > 1 ? 1.0 / @frequency : read_delta_t
        end

        def read_frequency fn=:frequency
          read_single_token(fn).to_i
        end

        def read_delta_t fn=:deltat
          deltat = read_single_token(fn)
          deltat =~ float_re ? deltat.to_f : deltat.to_i
        end

        # Returns either two integers (time and sample number) or a number (time) and nil
        def read_time fn=nil
          time  = read_single_line(fn)
          if time.size == 2 # vector of two integers
            time.map { |t| t.to_i }
          else # single number
            single = time.first
            single =~ float_re ? single.to_f : single.to_i
            [single, nil]
          end
        end
      end


      # class 'ts' in R
      class RTimeSeries < RTimeSeriesBase
        attr_reader :data, :levels
        
        def initialize id
          super id
          @data = @data.to_a # Convert from RNumeric to array.
        end

      protected
        def assign_properties
          super
          @data       = r("c(#{rob})") # Repeat for the data, which is probably of type Numeric.
        end
      end

      # class 'mts' in R
      class RMultiTimeSeries < RTimeSeriesBase
        attr_reader :row_names, :columns
        
        def col_names
          columns.keys
        end

        def levels col_name
          columns[col_name].levels
        end

      protected
        def assign_properties
          @row_names = read_row_names
          col_names  = read_col_names
          @columns   = read_columns(col_names)
          super
        end
      end


      # Represents a .tab file in R. Only handles reading. e.g., morley.tab in R data.
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