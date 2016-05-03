require File.expand_path(File.join(__FILE__, '..', 'scripts', 'helper.rb'))

Gem::Specification.new do |s|
  s.name        = __FILE__.sub('.gemspec', '')
  s.date        = Date.today.to_s
  s.version     = SciRuby::VERSION
  s.authors     = ['SciRuby Development Team']
  s.email       = ['sciruby-dev@googlegroups.com']
  s.license     = 'BSD'
  s.homepage    = 'http://sciruby.com'
  s.summary     =
  s.description = "Scientific gems for Ruby. #{__FILE__ =~ /full/ ? 'This is the full installation with rigid version constraints.' : 'See the sciruby-full gem for a full installation of many compatible scientific gems.'}"

  if __FILE__ =~ /full/
    s.files = %w(CHANGES CONTRIBUTING.md README.md LICENSE sciruby-full.gemspec)

    s.add_runtime_dependency 'sciruby', "= #{SciRuby::VERSION}"
    Helper.installed_gems.each {|gem| s.add_runtime_dependency gem[:name], "= #{gem[:installed_version]}" }
  else
    s.files = `git ls-files`.split($/)
    s.files.delete 'sciruby-full.gemspec'

    m = "Please consider installing 'sciruby-full' or the following gems:\n"
    Helper.all_gems.each {|gem| m << "  * #{gem[:name]} - #{gem[:description]}\n" }
    s.post_install_message = m << "\n"
  end
end
