module SciRuby
  # @api public
  class Gems
    # Return map of all known SciRuby gems
    attr_reader :all

    # Modules which can be autoloaded
    attr_reader :autoload_modules

    # Return map of all installed SciRuby gems
    def installed
      @installed ||=
        begin
          require 'rubygems'
          Hash[all.map {|name, options| installed_gem(name, options) }.compact]
        end
    end

    # Return list of all known SciRuby modules
    def all_modules
      @all_modules ||= all.map { |name, options| options[:module] }.flatten
    end

    # Return list of all installed SciRuby modules
    def installed_modules
      @installed_modules ||= installed.map { |name, options| options[:module] }.flatten
    end

    # Initialize gem list
    def initialize(file)
      @all, @autoload_modules = {}, {}
      YAML.load_file(file).each do |name, options|
        options = Hash[options.map {|k,v| [k.to_sym, v] }]
        options[:require] = [*(options[:require] || name)]
        options[:module] = name.capitalize unless options.include?(:module)
        options[:module] = [*options[:module]].map(&:to_sym)
        options[:module].each {|mod| @autoload_modules[mod] = options[:require] }
        @all[name] = options
      end
    end

    private

    def installed_gem(name, options)
      [name, options.merge(gem_version: Gem::Specification.find_by_name(name).version.to_s)]
    rescue Exception
      nil
    end
  end

  @gems = Gems.new(File.expand_path(File.join(__FILE__, '..', '..', '..', 'gems.yml')))
  class << self
    attr_reader :gems
  end
end
