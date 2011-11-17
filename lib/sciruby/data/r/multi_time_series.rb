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
# === multi_time_series.rb
#

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
