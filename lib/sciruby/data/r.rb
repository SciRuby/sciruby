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
      end

      def in_data_dir &block; SciRuby::Data::R.in_data_dir { yield } ; end


      def dataset id
        in_data_dir do
          if File.exist? "#{id}.tab"
            return parse_tab(File.read("#{id}.tab"))
          end
        end

        raise(NotImplementedError, "Need to handle non-tab format data")
      end

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
          fields.unshift('') if entries.size > fields.size && first_line =~ /^ /

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

        h.to_dataset
      end

      def search args={}
        parse_datasets_index(r.eval! { %q{library(help="datasets")} })
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

          STDERR.puts "line=#{line}"

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

      def r
        @r ||= ::Simpler.new
      end
    end
  end
end