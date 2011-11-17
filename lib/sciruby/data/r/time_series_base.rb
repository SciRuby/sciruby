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
# === time_series_base.rb
#

module SciRuby::Data
  class R
    # classes 'mts' and 'ts' in R; not instantiated directly. Use RTimeSeries or RMultiTimeSeries.
    class TimeSeriesBase < Base
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
  end
end
