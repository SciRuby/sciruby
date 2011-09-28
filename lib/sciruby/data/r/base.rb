module SciRuby::Data
  class R
    # Parses datasets from R directly.
    class Base
      FLOAT_RE = /([.eE])/

      require "simpler"

      def initialize id
        @rob  = id # R object name

        assign_properties # Read as many properties as possible from R
      end

      def self.class obj
        STDERR.puts "obj=#{obj}"
        Base.new(obj).send :read_class
      end

      attr_reader :rob
      alias_method :rname, :rob

    protected
      def assign_properties; end

      def r obj=nil
        SciRuby::Data::R.r(obj)
      end

      def float_re
        SciRuby::Data::R::Base::FLOAT_RE
      end

      def call_function fn=nil
        STDERR.puts "Call function: #{fn.to_s}\t#{rob}"
        fn.nil? ? r.eval! { rob } : r.eval! { "#{fn.to_s}(#{rob})" }
      end

      def call_property prop
        r.eval! { "#{rob}$'#{prop.to_s}'"}
      end

      def read_class fn=:class
        x = read_single_line(fn).first
        STDERR.puts "fn=#{fn}\tx=#{x}"
        x
      end

      def read_single_line fn=nil
        line = call_function fn
        STDERR.puts "rsl Got back: #{line}"
        CSV::parse_line(line.split(' ', 2).tap{ |s| s.shift }.first, :col_sep => ' ')
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
        if lines.first =~ /^ *\[/
          return lines.map do |line|
            remaining_line = CSV::parse_line(line.split(' ', 2).tap { |s| s.shift }.first, :col_sep => ' ')
            remaining_line = remaining_line.tap { |l| l.pop } if remaining_line.last.nil?
            remaining_line
          end.flatten
        end

        raise "Unrecognized R output"
      end

      def read_row_names fn='rownames'
        attempt = read_multiple_lines(fn) # may return nil if no rownames found.
        return [] if attempt.nil?
        attempt
      end

      def read_col_names fn='colnames'
        read_row_names fn
      end

      def read_names fn='names'
        read_row_names fn
      end

      def read_levels fn='levels'
        read_row_names fn
      end

      def read_columns fields
        columns = {}
        fields.each do |field|
          raise(ArgumentError, "nil field") if field.nil?
          columns_for_field = SciRuby::Data::R.r("#{rob}[,'#{field.to_s}']")
          columns[field] = (columns_for_field.is_a?(Vector) && columns_for_field.has_levels?) || columns_for_field.is_a?(TimeSeries) ? columns_for_field : columns_for_field.to_a
        end
        columns
      end

    end
  end
end