module SciRuby
  extend self

  # Return map of all known SciRuby gems
  def gems
    @gems ||= {}
  end

  # Modules which can be autoloaded
  def autoload_modules
    @autoload_modules ||= {}
  end

  # Return map of all installed SciRuby gems
  def installed_gems
    @installed_gems ||=
      begin
        require 'rubygems'
        Hash[gems.each_value.map(&method(:installed_gem)).compact]
      end
  end

  # Return list of all known SciRuby modules
  def modules
    @modules ||= gems.each_value.map {|gem| gem[:module] }.flatten
  end

  # Return list of all installed SciRuby modules
  def installed_modules
    @installed_modules ||= installed_gems.each_value.map {|gem| gem[:module] }.flatten
  end

  private

  def load_gems(file)
    YAML.load_file(file).each do |name, gem|
      gem = Hash[gem.map {|k,v| [k.to_sym, v] }]
      gem[:name] = name
      gem[:require] = [*(gem[:require] || name)]
      gem[:module] = [*gem[:module]].map(&:to_sym)
      gem[:module].each {|mod| autoload_modules[mod] = gem[:require] }
      gems[name] = gem
    end
  end

  def installed_gem(gem)
    [gem[:name], gem.merge(installed_version: Gem::Specification.find_by_name(gem[:name]).version.to_s)]
  rescue Exception
    nil
  end

  GEMS_YML = File.expand_path(File.join(__FILE__, '..', '..', '..', 'gems.yml'))
  load_gems GEMS_YML
end
