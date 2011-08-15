module Rubyvis
  module Scale
    class Ordinal
      def size
        @r.size
      end
    end
  end
end

# Added by John O. Woods.
#
# Methods for quantifying the predictive abilities of binary classifier systems (i.e., true positives, false positives,
# etc.)

module SciRuby
  module Validation
    # Binary confusion matrix for generating Receiver Operating Characteristic (ROC) and Precision-Recall curves.
    class Binary
      DEFAULT_VIS_OPTIONS = {
        :width  => 400,
        :height => 400,
        :left   => 20,
        :bottom => 20,
        :right  => 10,
        :top    => 5,
        :line_color => "#66abca",
        :line_width => 2
      }

      # Create a new confusion matrix, with +total_positives+ as the number of items that are known to be correct.
      # +initial_negatives+ is the total number of items to be tested as we push each prediction/set of predictions.
      def initialize initial_negatives, total_positives
        raise(ArgumentError, "total predictions should be greater or equal to total positives") unless initial_negatives >= total_positives
        @tp, @p, @tn, @n = [0], [0], [initial_negatives - total_positives], [initial_negatives]
        @threshold = { 1.0 => 0 }
        @roc_area = 0.0
      end

      # Allows us to zoom right in on a specific score and find out how many positives have been hit by the time
      # we've gotten that far down the list.
      attr_reader :threshold

      # True positives axis
      attr_reader :tp
      alias :tp_axis :tp
      alias :true_positives_axis :tp

      # Positives (true and false) axis
      attr_reader :p
      alias :p_axis :p
      alias :positives_axis :p

      # True negatives axis
      attr_reader :tn
      alias :tn_axis :tn
      alias :true_negatives_axis :tn

      # Negatives (true and false) axis
      attr_reader :n
      alias :n_axis :n
      alias :negatives_axis :n

      # Area under the Receiver-Operating Characteristic (ROC) curve.
      attr_reader :roc_area

      # Data for a visualization/plot
      def data type
        if type == :roc
          fpr_axis.zip(tpr_axis)
        elsif type == :precision_recall
          tpr_axis.zip(precision_axis)
        else
          raise ArgumentError, "Unrecognized plot type: #{type.to_s}"
        end
      end

      class << self

        # Generate an empty panel.
        def vis options = {}
          options.reverse_merge! DEFAULT_VIS_OPTIONS
          
          x = Rubyvis::Scale.linear(0.0, 1.0).range(0, options[:width])
          y = Rubyvis::Scale.linear(0.0, 1.0).range(0, options[:height])

          v = Rubyvis::Panel.new do
            width     options[:width]
            height    options[:height]
            bottom    options[:bottom]
            left      options[:left]
            right     options[:right]
            top       options[:top]
          end

          v.add(pv.Rule).
              data(y.ticks()).
              bottom(y).
              strokeStyle( lambda {|dd| dd != 0 ? "#eee" : "#000"} ).
            anchor("left").add(pv.Label).
            visible( lambda {|dd|  dd > 0 and dd < 1} ).
            text(y.tick_format)

          # X-axis and ticks.
          v.add(pv.Rule).
              data(x.ticks()).
              left(x).
              stroke_style( lambda {|dd| dd != 0 ? "#eee" : "#000"} ).
            anchor("bottom").add(pv.Label).
            visible( lambda {|dd|  dd > 0 and dd < 1} ).
            text(x.tick_format)

          v
        end

        # Plot an array of curves, or a hash of real and control curves. Kind of cluttered.
        def plot hsh_or_ary, type, options = {}
          vis = begin
            if hsh_or_ary.is_a?(OpenStruct)
              plot_hash hsh_or_ary, type, options
            elsif hsh_or_ary.is_a?(Array)
              plot_array hsh_or_ary, type, options
            end
          end

          vis.render()
          f = File.new("output.svg", "w")
          f.puts vis.to_svg
          f.close

          `inkscape output.svg`
        end

      protected
        # Plot :real and :control arrays on the same panel. Not really very useful, as it gets too cluttered.
        def plot_hash hsh, type, options = {}
          options[:colors] ||= :category10
          options[:line_width] ||= 2

          colors = Rubyvis::Colors.send(options[:colors])
          options[:panel] = vis(options) # set up panel and store it in the options hash
          
          hsh.real.each_index do |i|
            options[:panel] = hsh.real[i].vis(type, options.merge({ :line_color => colors[i % colors.size] }))
          end if hsh.respond_to?(:real) # may not have anything but controls

          hsh.control.each_index do |i|
            options[:panel] = hsh.control[i].vis(type, options.merge({ :line_color => colors[i % colors.size] }))
          end if hsh.respond_to?(:control) # May not have a control set up

          options[:panel]
        end


        # Plot multiple Validation::Binary objects on the same panel.
        def plot_array ary, type, options = {}

          options[:colors] ||= :category10
          colors = Rubyvis::Colors.send(options[:colors])

          options[:panel] = vis(options) # set up panel
          ary.each_index do |i|
            options[:panel] = ary[i].vis(type, options.merge({:line_color => colors[i % colors.size]}))
          end

          options[:panel]
        end
      end

      # RubyVis object for a plot
      def vis type, options = {}
        options.reverse_merge! DEFAULT_VIS_OPTIONS

        d = data(type)

        x = Rubyvis::Scale.linear(0.0, 1.0).range(0, options[:width])
        y = Rubyvis::Scale.linear(0.0, 1.0).range(0, options[:height])

        # Use existing panel or create new empty one
        v = options.has_key?(:panel) ? options[:panel] : self.class.send(:vis, options)

        v.add(Rubyvis::Panel).
            data(d).
            add(Rubyvis::Dot).
            left(lambda { |dd| x.scale(dd[0])} ).
            bottom(lambda { |dd| y.scale(dd[1])} ).
            stroke_style("black").
            shape_size(2).
            title(lambda { |dd| "%0.1f" % dd[1]} )

        v.add(Rubyvis::Line).
            data(d).
            line_width(options[:line_width]).
            left(lambda { |dd| x.scale(dd[0])} ).
            bottom(lambda { |dd| y.scale(dd[1])} ).
            stroke_style(options[:line_color]).
            anchor("bottom")
        
        v
      end


      # Plot on a new or existing panel. To use an existing panel, just set option :panel to be a
      # Rubyvis::Panel object.
      #
      # To use a new panel, just don't set :panel. You can provide various options as for the vis()
      # method.
      #
      # The first argument should be the type of plot, :roc or :precision_recall.
      def plot type, options = {}
        v = vis(type, options)

        v.render()
        f = File.new("output.svg", "w")
        f.puts v.to_svg
        f.close

        `inkscape output.svg`

        self
      end


      # Get the "actual" precision at some recall value.
      def precision_at_fraction_recall val
        @p.each_index do |i|
          return actual_precision(i) if tpr(i) < val
        end
        0.0
      end

      # Push the number of predicted and the number of correctly predicted for a given score. ROC area thus far is
      # calculated instantly and returned.
      def push predicted, correctly_predicted, score = nil
        raise(ArgumentError, "Requires two integers as arguments") unless predicted.is_a?(Fixnum) && correctly_predicted.is_a?(Fixnum)
        raise(ArgumentError, "First argument should be greater than or equal to second argument") unless predicted >= correctly_predicted

        @threshold[score] = @p.size unless score.nil?

        last_i = p.size - 1
        i      = p.size

        @p << @p[last_i] + predicted
        @n << @n[last_i] - predicted

        @tp << @tp[last_i] + correctly_predicted
        @tn << @tn[last_i] - predicted + correctly_predicted

        delta_tpr = tpr(i) - tpr(last_i)
        delta_fpr = fpr(i) - fpr(last_i)

        @roc_area += (tpr(last_i) + 0.5 * delta_tpr) * delta_fpr
      end

      # Some methods you'd want to validate don't offer scores for each and every item. In that case, just call
      # push_remainder in order to ensure the line gets drawn all the way to the right.
      def push_remainder
        # push all remaining negatives, none correct, score of 0.
        push n.last, n.first - tn.first, 0.0
      end

      # Given some bin +i+, what is the true positive rate / sensitivity / recall
      def tpr(i)
        [ @tp[i].quo(@tp[i] + @n[i] - @tn[i]), 1 ].min
      end
      alias :sensitivity :tpr
      alias :recall :tpr

      # Given some bin +i+, what is the false positive rate / fallout?
      def fpr(i)
        begin
          [ (@p[i] - @tp[i]).quo(@p[i] - @tp[i] + @tn[i]), 1 ].min
        rescue ZeroDivisionError => e
          STDERR.puts "TP axis: #{tp_axis.inspect}"
          STDERR.puts "P axis: #{p_axis.inspect}"
          STDERR.puts "TN axis: #{tn_axis.inspect}"
          STDERR.puts "N axis: #{n_axis.inspect}"
          raise ZeroDivisionError, "i=#{i}, p[i]=#{@p[i]}, tp[i]=#{@tp[i]}, tn[i]=#{@tn[i]}"
        end
      end
      alias :fallout :fpr

      # Calculate the actual precision at some point.
      #
      # This is used because a precision-recall curve actually levels out the stair-steps, and sometimes you need
      # the true value instead.
      #
      # To get the leveled-out values, you would use precision_axis_and_area or just precision_axis.
      def actual_precision(i)
        return 1 if @p[i] == 0 # Prevents ZeroDivisionError.
        begin
          [ @tp[i].quo(@p[i]), 1 ].min
        rescue ZeroDivisionError => e
          STDERR.puts "TP axis: #{tp_axis.inspect}"
          STDERR.puts "P axis: #{p_axis.inspect}"
          STDERR.puts "TN axis: #{tn_axis.inspect}"
          STDERR.puts "N axis: #{n_axis.inspect}"
          raise ZeroDivisionError, "i=#{i}, p[i]=#{@p[i]}, tp[i]=#{@tp[i]}, tn[i]=#{@tn[i]}"
        end
      end

      # True positive rate axis (as we walk through the list of predictions from best-scored to worst-scored)
      def tpr_axis
        axis = []
        @p.each_index do |i|
          axis << tpr(i)
        end
        axis
      end

      # False positive rate axis
      def fpr_axis
        axis = []
        @p.each_index do |i|
          axis << fpr(i)
        end
        axis
      end

      # Precision axis for a precision-recall plot; and the area under the precision-recall curve.
      #
      # Returns an OpenStruct with two attributes: precision_axis (an array), and area (a Fixnum).
      def precision_axis_and_area
        prec = Array.new(@p.size)
        area = 0.0
        i    = @p.size - 1
        max  = prec[i]   = actual_precision(i); i -= 1

        while i >= 0
          max   = prec[i] = [max, actual_precision(i)].max
          area += ( tpr(i+1).to_f - tpr(i).to_f ) * max

          i -= 1
        end
        prec[0] = 1.0

        OpenStruct.new({:precision_axis => prec, :area => area})
      end

      # Returns the number of prediction score bins.
      def bins
        @p.size - 1
      end

      # Returns the size of the plot (for axes).
      def size
        @p.size
      end

      # Returns the total number of predictions, correct and incorrect.
      def max
        @n[0]
      end

      # Returns the total number of known values.
      def known
        @n[0] - @tn[0]
      end

      # Returns just the precision axis without the area. Note that it takes just as long to calculate; this just
      # leaves off the area if you don't need it.
      def precision_axis
        precision_axis_and_area.precision_axis
      end

    end
  end
end
