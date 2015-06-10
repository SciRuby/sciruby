# coding: utf-8
$: << File.join(__FILE__, '..', 'scripts')
require 'helper'

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

  if SCIRUBY_FULL
    s.files = %w(CHANGES CONTRIBUTING.md README.md LICENSE sciruby-full.gemspec)

    s.add_runtime_dependency 'sciruby', "= #{SciRuby::VERSION}"
    Helper.sciruby_gems(true).each {|gem| s.add_runtime_dependency gem[:name], *gem[:version] }
  else
    s.require_paths = %w(lib)
    s.files = `git ls-files`.split($/)
    s.files.delete 'sciruby-full.gemspec'

    m = "Please consider installing 'sciruby-full' or the following gems:\n"
    Helper.sciruby_gems(false).each {|gem| m << "  * #{gem[:name]} - #{gem[:description]}\n" }
    s.post_install_message = m << "\n"
  end
end
