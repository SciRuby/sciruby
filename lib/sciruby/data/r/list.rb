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
# === list.rb
#

module SciRuby::Data
  class R
    # An intermediate object that doesn't really get used -- immediately gets converted to a Ruby Hash of other R objects.
    class List < Base
      def to_h
        @data
      end
    protected
      def assign_properties
        @names = read_names
        @names = nil if @names.nil? || (@names.is_a?(Array) && @names.empty?)

        @data = {}
        @names.each do |list_item|
          @data[list_item] = r("#{rob}[['#{list_item}']]")
        end
      end
    end
  end
end