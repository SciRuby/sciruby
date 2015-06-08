# coding: utf-8
$: << File.join(File.dirname(__FILE__), 'lib')
require 'sciruby'
require 'date'

SCIRUBY_FULL = false unless defined?(SCIRUBY_FULL)

Gem::Specification.new do |s|
  s.name        = SCIRUBY_FULL ? 'sciruby-full' : 'sciruby'
  s.date        = Date.today.to_s
  s.version     = SciRuby::VERSION
  s.authors     = ['SciRuby Development Team']
  s.email       = ['sciruby-dev@googlegroups.com']
  s.license     = 'BSD'
  s.homepage    = 'http://sciruby.com'
  s.summary     =
  s.description = "Scientific gems for Ruby#{SCIRUBY_FULL ? ' (Full installation)' : ''}"

  s.require_paths = %w(lib)
  s.files = `git ls-files`.split($/)

  if SCIRUBY_FULL
    s.files.delete 'sciruby.gemspec'
    s.files.reject! {|f| f =~ /\Alib/ }

    s.add_runtime_dependency 'sciruby', "= #{SciRuby::VERSION}"
    SciRuby.gems.each {|name, options| s.add_runtime_dependency name, *options[:version] }
  else
    s.files.delete 'sciruby-full.gemspec'

    m = "Please consider installing 'sciruby-full' or the following gems:\n"
    SciRuby.gems.each {|name, options| m << "  * #{name}\n" }
    s.post_install_message = m << "\n"
  end
end
