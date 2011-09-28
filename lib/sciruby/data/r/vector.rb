module SciRuby::Data
  class R
    class Vector < Base
      attr_reader :data, :levels
      alias_method :to_a, :data

      def has_levels?
        return @levels.nil?
      end

      def to_h
        return has_levels? ? {:data => @data, :levels => @levels} : {:data => @data}
        {:data => @data}
      end

    protected
      def assign_properties
        @names = read_names
        @names = nil if @names.nil? || (@names.is_a?(Array) && @names.empty?)
        STDERR.puts "@names = #{@names.inspect}"

        @levels = read_levels
        @levels = nil if @levels.nil? || (@levels.is_a?(Array) && @levels.empty?)
        STDERR.puts "@levels = #{@levels.inspect}"

        @data = read_array_data
      end

      def max_col_width
        names_width = @names.nil? ? 0 : @names.collect { |n| n.size }.max + 1
        levels_width = @levels.nil? ? 0 : @levels.collect { |l| l.size }.max + 1
        [names_width, levels_width].max
      end

      def read_multiple_lines fn=nil
        col_width = max_col_width
        STDERR.puts "col_width = #{col_width}"
        return super(fn) if col_width == 0
        
        lines = (block_given? ? yield : call_function(fn)).split("\n")
        STDERR.puts "rml_ Got back:\n#{lines.join("\n")}"

        lines.delete_if { |line| line !~ /^ *\[/ }

        return nil if lines.first =~ /^NULL/

        if lines.first =~ /^ *\[/
          return lines.map do |line|
            entries = []
            next unless line =~ /^ *\[/
            line = line.split(' ', 2).tap { |s| s.shift }.first
            entries << line.slice!(0, col_width).strip while line.size > 0
            entries
          end.flatten
        end
      end

      def read_multiple_lines_named fn=nil
        col_width = max_col_width

        lines = (block_given? ? yield : call_function(fn)).split("\n")
        STDERR.puts "rmln Got back:\n#{lines.join("\n")}"

        return nil if lines.first =~ /^NULL/

        index   = 0
        keys    = []
        entries = []

        lines.each do |line|
          words = []
          words << line.slice!(0, col_width) while line.size > 0
          words.map! { |w| w.strip }

          if index % 2 == 0
            keys.concat words
          else
            entries.concat CSV::parse_line(words.join(','), :col_sep => ',')
          end
          index += 1
        end

        h = {}
        keys.each_index do |i|
          h[keys[i]] = entries[i]
        end
        h
      end

      def read_array_data fn=nil
        entries = @names.nil? ? read_multiple_lines(fn) : read_multiple_lines_named(fn)
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
  end
end