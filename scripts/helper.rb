begin
  require 'bundler/setup'
rescue Exception
end

$: << File.join(File.dirname(__FILE__), '..', 'lib')

require 'sciruby'
require 'date'
require 'rubygems'

module Enumerable
  def stable_sort_by
    sort_by.with_index {|e, i| [yield(e), i] }
  end
end

module Helper
  extend self

  def sort_hash(object)
    if Hash === object
      res = {}
      object.each {|k, v| res[k] = sort_hash(v) }
      Hash[res.sort_by {|a| a[0].to_s }]
    elsif Array === object
      array = []
      object.each_with_index {|v, i| array[i] = sort_hash(v) }
      array
    else
      object
    end
  end

  def check_gem(name, gem)
    gem[:name].must_equal name
    gem.must_be_instance_of Hash
    gem.each_key {|k| k.must_be_instance_of Symbol }
    gem[:category].must_be_instance_of String
    gem[:description].must_be_instance_of String
    gem[:exclude].must_be_instance_of String if gem[:exclude] != nil
    gem[:module].must_be_instance_of Array
    gem[:require].must_be_instance_of Array
    gem[:require].empty?.must_equal false

    if gem[:exclude] || gem[:maintainer] == 'stdlib' || %w(sciruby sciruby-full).include?(gem[:name])
      gem[:version].must_be_nil
    else
      gem[:version].must_be_instance_of String
    end
  end

  def fetch_spec(gem)
    #STDERR.puts "Fetching #{gem[:name]}..."
    gem[:maintainer] != 'stdlib' && Gem::SpecFetcher.fetcher.spec_for_dependency(Gem::Dependency.new(gem[:name])).flatten.first
  end

  def gem_status(gem)
    status = []
    status << [:default, "Excluded: #{gem[:exclude]}"] if gem[:exclude]
    if spec = fetch_spec(gem)
      status << [Time.now - spec.date > 4*365*24*3600 ? :danger : :warning, "Last update #{spec.date.strftime '%Y-%m-%d'}"] if Time.now - spec.date > 2*365*24*3600
      status << [:danger, 'Outdated version constraint'] if gem[:version] && !Gem::Dependency.new(gem[:name], *gem[:version]).matches_spec?(spec)
    else
      status << [:danger, 'Gem not found'] unless gem[:exclude] || gem[:maintainer] == 'stdlib'
    end
    status << [:success, 'OK'] if status.empty?
    status.sort_by(&:first)
  end

  def sorted_gems
    SciRuby.gems.each_value.
      stable_sort_by {|gem| gem[:name] }.
      stable_sort_by {|gem| gem[:category] }.
      stable_sort_by {|gem| gem[:maintainer] == 'sciruby' ? 0 : (gem[:maintainer] ? 1 : 2) }
  end

  def sciruby_gems(exclude)
    SciRuby.gems.each_value.sort_by {|gem| gem[:name] }.reject do |gem|
      gem[:maintainer] == 'stdlib' || %w(sciruby sciruby-full).include?(gem[:name])
    end.reject {|gem| gem[:exclude] && exclude }
  end
end
