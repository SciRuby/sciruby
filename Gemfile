$: << File.join(File.dirname(__FILE__), 'lib')
require 'sciruby'

source 'https://rubygems.org'

SciRuby.gems.all.each do |name, options|
  gem name, *options[:version], require: options[:require].first
end
