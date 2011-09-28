module SciRuby::Data
  class R
    # class 'mts' in R
    class MultiTimeSeries < TimeSeriesBase
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
  end
end
