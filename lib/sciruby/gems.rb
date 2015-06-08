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
        Hash[gems.map {|name, options| installed_gem(name, options) }.compact]
      end
  end

  # Return list of all known SciRuby modules
  def modules
    @modules ||= gems.map {|name, options| options[:module] }.flatten
  end

  # Return list of all installed SciRuby modules
  def installed_modules
    @installed_modules ||= installed_gems.map {|name, options| options[:module] }.flatten
  end

  private

  def load_gems(file)
    YAML.load_file(file).each do |name, options|
      options = Hash[options.map {|k,v| [k.to_sym, v] }]
      options[:require] = [*(options[:require] || name)]
      options[:module] = name.capitalize unless options.include?(:module)
      options[:module] = [*options[:module]].map(&:to_sym)
      options[:module].each {|mod| autoload_modules[mod] = options[:require] }
      gems[name] = options unless options[:disabled]
    end
  end

  def installed_gem(name, options)
    [name, options.merge(gem_version: Gem::Specification.find_by_name(name).version.to_s)]
  rescue Exception
    nil
  end

  load_gems File.expand_path(File.join(__FILE__, '..', '..', '..', 'gems.yml'))
end
