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