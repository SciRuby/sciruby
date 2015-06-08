# coding: utf-8
require File.dirname(__FILE__) + '/lib/sciruby/version'
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
    File.read('Gemfile').scan(/gem\s+'(.*?)'/) { s.add_runtime_dependency $1, '~> 0' }
  else
    s.files.delete 'sciruby-full.gemspec'

    m = "Please consider installing 'sciruby-full' or the following gems:\n"
    File.read('Gemfile').scan(/gem\s+'(.*?)'/) { m << "  * #{$1}\n" }
    s.post_install_message = m << "\n"
  end
end
