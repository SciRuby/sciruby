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
# === time_series.rb
#


module SciRuby::Data
  class R
    # class 'ts' in R
    class TimeSeries < TimeSeriesBase
      attr_reader :data, :levels

      def initialize id
        super id
        @data = @data.to_a # Convert from R Vector to array.
      end

    protected
      def assign_properties
        super
        @data       = r("c(#{rob})") # Repeat for the data, which is probably of type Vector.
      end
    end
  end
end
