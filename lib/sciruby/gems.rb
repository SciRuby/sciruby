module SciRuby
  extend self

  def all_gems
    @all_gems ||= File.read(File.expand_path(File.join(__FILE__, '..', '..', '..', 'Gemfile'))).scan(/gem\s+'(.*?)'/).map(&:first)
  end

  def installed_gems
    @installed_gems ||=
      begin
        require 'rubygems'
        Hash[all_gems.map {|name| (v = gem_version(name)) && [name, v] }.compact]
      end
  end

  def require!
    installed_gems.each {|gem,_| require gem }
  end

  private

  def gem_version(name)
    Gem::Specification.find_by_name(name).version.to_s
  rescue Exception
    nil
  end
end
