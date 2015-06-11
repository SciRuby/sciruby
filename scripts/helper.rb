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

    if gem[:exclude] || gem[:owner] == 'stdlib' || %w(sciruby sciruby-full).include?(gem[:name])
      gem[:version].must_be_nil
    else
      gem[:version].must_be_instance_of String
    end
  end

  def fetch_spec(gem)
    #STDERR.puts "Fetching #{gem[:name]}..."
    dep = Gem::Dependency.new(gem[:name])
    spec = Gem::SpecFetcher.fetcher.spec_for_dependency(dep, false).flatten[-2]
    return spec if spec
    dep.prerelease = true
    Gem::SpecFetcher.fetcher.spec_for_dependency(dep, false).flatten[-2]
  end

  def gem_warnings(gem)
    warnings = []
    warnings << "Excluded: #{gem[:exclude]}" if gem[:exclude]
    if gem[:spec]
      warnings << "Last update #{gem[:date]}" if Time.now - gem[:spec].date > 2*365*24*3600
      warnings << 'Outdated version constraint' if gem[:version] && !Gem::Dependency.new(gem[:name], *gem[:version]).matches_spec?(gem[:spec])
      warnings << 'Github repository unknown' unless gem[:github]
    else
      warnings << 'Gem not found' unless gem[:exclude] || gem[:owner] == 'stdlib'
    end
    warnings << %{<a href="https://versioneye.com/ruby/#{gem[:name]}">Outdated dependencies</a>} if versioneye(gem[:name])
    warnings
  end

  def table_gems
    require 'parallel'
    require 'net/http'
    require 'json'

    owner_order = {
      'sciruby' => 0,
      'stdlib'  => 1
    }
    owner_order.default = 2

    status_order = {
      'ok'       => 0,
      'warnings' => 1,
      'exclude'  => 2
    }

    Parallel.map(SciRuby.gems.values, in_processes: 8) do |gem|
      gem = gem.dup

      if gem[:owner] == 'stdlib'
        gem[:homepage] = gem[:docs] = "http://ruby-doc.org/stdlib/libdoc/#{gem[:name]}/rdoc/"
        gem[:github] = "ruby/ruby/blob/trunk/lib/#{gem[:name]}.rb"
        gem[:module] = gem[:module].map {|mod| %{<a href="#{gem[:docs]}#{mod.gsub('::', '/')}.html">#{mod}</a>} }
      elsif spec = fetch_spec(gem)
        gem[:spec] = spec
        gem[:date] = spec.date.strftime('%Y-%m-%d')
        gem[:homepage] = spec.homepage
        gem[:docs] = "http://www.rubydoc.info/gems/#{gem[:name]}/#{spec.version}"
        gem[:module] = gem[:module].map {|mod| %{<a href="#{gem[:docs]}/#{mod.gsub('::', '/')}">#{mod}</a>} }
        github_infos(gem)
      end
      gem[:warnings] = gem_warnings(gem)

      if gem[:exclude]
        gem[:status] = 'exclude'
      elsif gem[:warnings].empty?
        gem[:status] = 'ok'
      else
        gem[:status] = 'warnings'
      end

      gem
    end.stable_sort_by {|gem| gem[:name] }.
      stable_sort_by {|gem| gem[:category] }.
      stable_sort_by {|gem| owner_order[gem[:owner]] }.
      stable_sort_by {|gem| status_order[gem[:status]] }
  end

  def github_infos(gem)
    if gem[:github] = github_name(gem)
      data = JSON.parse(Net::HTTP.get(URI("https://api.github.com/repos/#{gem[:github]}?client_id=#{ENV['CLIENT_ID']}&client_secret=#{ENV['CLIENT_SECRET']}")))
      gem[:issues] = data['open_issues_count']
      gem[:forks] = data['forks_count']
      gem[:stars] = data['stargazers_count']
      gem[:watchers] = data['watchers_count']
    end
  end

  def github_name(gem)
    return $1 if gem[:spec].homepage =~ %r{github.com/([^/]+/[^/]+)}
    JSON.parse(Net::HTTP.get(URI("https://rubygems.org/api/v1/gems/#{gem[:name]}.json"))).each do |k,v|
      return $1 if k =~ /_uri/ && v =~ %r{github.com/([^/]+/[^/]+)}
    end
    nil
  end

  def versioneye(name)
    Net::HTTP.get(URI("https://www.versioneye.com/ruby/#{name}/badge")) =~ /out of date/
  end

  def sciruby_gems(exclude)
    SciRuby.gems.each_value.sort_by {|gem| gem[:name] }.reject do |gem|
      gem[:owner] == 'stdlib' || %w(sciruby sciruby-full).include?(gem[:name])
    end.reject {|gem| gem[:exclude] && exclude }
  end
end
