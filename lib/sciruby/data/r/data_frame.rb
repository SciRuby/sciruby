module SciRuby::Data
  class R
    class DataFrame < Base
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
  end
end