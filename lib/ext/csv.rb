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
# === csv.rb
#

require 'csv'
require 'statsample'

class CSV
  def to_dataset mode=:col
    CSV::Table.new(self).send("by_#{mode}.to_s".to_sym).to_dataset
  end
end

class CSV::Table
  def to_dataset
    begin
      h = {}
      self.headers.each { |header|  h[header] = self[header].to_scale }
      h
    rescue NoMethodError => e # Table has no headers. Try a different way.
      v = []
      0.upto(self.size-1).each { |j|  v[j] = self[j].to_scale }
      v
    end.to_dataset
  end
end