$: << File.join(__FILE__, '..', '..', 'lib')
require 'sciruby'
require 'rubygems'

module Enumerable
  def stable_sort_by
    sort_by.with_index {|e, i| [yield(e), i] }
  end
end

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

def get_status(gem)
  STDERR.puts "Fetching #{gem[:name]}..."
  spec = Gem::SpecFetcher.fetcher.spec_for_dependency(Gem::Dependency.new(gem[:name])).flatten.first

  status = { danger: [], warning: [] }
  status[:danger] << "Not in sciruby-full: #{gem[:exclude]}" if gem[:exclude]
  if gem[:maintainer] != 'stdlib'
    if spec
      status[:warning] << "No update since #{spec.date.strftime '%Y-%m-%d'}" if Time.now - spec.date > 2*365*24*3600
      unless %w(sciruby sciruby-full).include?(gem[:name])
        if gem[:version]
          status[:danger] << "Outdated version, found #{spec.version}" unless Gem::Dependency.new(gem[:name], *gem[:version]).matches_spec?(spec)
        else
          status[:danger] << "No version constraint, found #{spec.version}" unless gem[:exclude]
        end
      end
    else
      status[:danger] << 'Gem not found' unless gem[:exclude]
    end
  end
  status[:success] = ['OK'] if status.values.flatten.empty?

  status
end
