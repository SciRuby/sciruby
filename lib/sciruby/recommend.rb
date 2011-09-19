require 'set'
require 'distribution' # for Hypergeometric

warn "[DEPRECATION] SciRuby::Recommend is deprecated."

unless defined?(SortedSet) # Ruby 1.8
  class SortedSet < Set
  end
end

# Added by John O. Woods.
#
# Makes use of Distribution gem, formerly part of Statsample, by Claudio Bustos.

module SciRuby
  # Methods and classes for expert recommendation systems.
  #
  # This module is likely to go away soon.
  module Recommend
    # Set Distance functions: determine distances between sets.
    #
    # These functions may be useful for k-nearest neighbors searches and expert recommendation systems.
    #
    # Sets are used for systems where vectors are binary. For example, if you have a matrix of customers and products, a
    # zero means the customer has not bought the product, and a one means the customer has. There is no concept of
    # degree.
    #
    # Pearson is probably the function most people will want to use.
    class SetDistance

      # Create a new recommendation-by-set-distance object. This requires as arguments two sets (+a+ and +b+) and a
      # +total+ size which indicates the number of items from which the sets are drawn.
      #
      # It also takes an optional +distance_function+ (e.g., :hypergeometric or :pearson). If this is given, the distance
      # will be calculated immediately. Otherwise, you can use the various distance functions to calculate distance by
      # a variety of metrics (e.g., distance_hypergeometric, distance_pearson, and so on).
      def initialize a, b, total, distance_function = nil
        @a = a.is_a?(Set) ? a : SortedSet.new(a)
        @b = b.is_a?(Set) ? b : SortedSet.new(b)
        @total = total

        unless distance_function.nil? # Calculate immediately if a distance function is given.
          @distance_function = "distance_#{distance_function.to_s}".to_sym
          @distance = self.send @distance_function
        end
      end

      attr_reader :a, :b, :total, :distance

      def m; a.size; end
      def n; b.size; end
      def ab; @ab ||= a.intersection(b); end
      def k; ab.size; end
      alias :a_dot_b :k

      # Calculate distance as the hypergeometric probability of seeing an intersection of +k+ or greater between two sets
      # +a+ and +b+. This is basically the complement of cdf(+k-1+, +m+, +n+, +total+).
      def distance_hypergeometric
        @distance_hypergeometric ||= 1.0 - Distribution::Hypergeometric.cdf(k-1, m, n, total)
      end

      # The generalization of Pearson correlation coefficient using binary vectors.
      def distance_pearson
        @distance_pearson ||= 1.0 - (total * a_dot_b - m*n).abs / Math.sqrt(  (total - m)*(total - n)*m*n    )
      end
      
    end

  end
end