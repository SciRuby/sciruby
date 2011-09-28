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
