# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sciruby"
  s.version = "0.1.3.20110919135244"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["SciRuby Development Team"]
  s.date = "2011-09-19"
  s.description = "Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and visualization libraries in Ruby.\n\nWe are not the first with this idea, but we are trying to bring it to life.\n\nAt this point, SciRuby has not much to offer. But if you install this gem, you'll get as dependencies all of the libraries that we plan to incorporate into SciRuby."
  s.email = ["sciruby-dev@googlegroups.com"]
  s.executables = ["sciruby-plotter"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".autotest", "History.txt", "Manifest.txt", "readme.md", "Rakefile", "lib/sciruby.rb", "lib/sciruby/validation.rb", "lib/sciruby/recommend.rb", "lib/sciruby/plotter.rb", "lib/sciruby/editor.rb", "lib/ext/shoes.rb", "bin/sciruby-plotter", "static/sciruby-icon.png", "test/test_recommend.rb", "test/helpers_tests.rb", ".gemtest"]
  s.homepage = "http://sciruby.com"
  s.post_install_message = "***********************************************************\nWelcome to SciRuby: Tools for Scientific Computing in Ruby!\n\n                     *** WARNING ***\nPlease be aware that SciRuby is in ALPHA status. If you're\nthinking of using SciRuby to write mission critical code,\nsuch as for driving a car or flying a space shuttle, you\nmay wish to choose other software (for now).\n\nIn order to leverage the GUI features, you will need to\ninstall gtk2 and optionally gtksourceview2:\n\n  $ gem install gtk2 gtksourceview2\n\nYou will probably first need to install the headers for\na number of required packages. In Ubuntu, use:\n\n  $ sudo apt-get install libgtk2.0-dev libgtksourceview2-dev       librsvg2-dev libcairo2-dev\n\nIf you have trouble with Green Shoes, you should look at\nthe Green Shoes wiki:\n\nhttp://github.com/ashbb/green_shoes/wiki\n\nFor Mac OSX Green Shoes:\n\nhttps://github.com/ashbb/green_shoes/wiki/Building-Green-Shoes-on-OSX\n\nMore explicit instructions for SciRuby should be available\nat our website, sciruby.com, or through our mailing list\n(which can also be found on our website).\n\nThanks for installing SciRuby! Happy hypothesis testing!\n\n***********************************************************\n"
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9")
  s.rubyforge_project = "sciruby"
  s.rubygems_version = "1.8.10"
  s.summary = "Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python"
  s.test_files = ["test/test_recommend.rb"]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<distribution>, [">= 0.4.0"])
      s.add_runtime_dependency(%q<green_shoes>, [">= 1.0.282"])
      s.add_runtime_dependency(%q<statsample>, [">= 1.1.0"])
      s.add_runtime_dependency(%q<integration>, [">= 0"])
      s.add_runtime_dependency(%q<minimization>, [">= 0"])
      s.add_runtime_dependency(%q<gsl>, ["~> 1.14.5"])
      s.add_runtime_dependency(%q<rsvg2>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<rubyvis>, [">= 0.4.0"])
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 2.0"])
      s.add_development_dependency(%q<haml>, [">= 0"])
      s.add_development_dependency(%q<coderay>, [">= 0"])
      s.add_development_dependency(%q<nokogiri>, [">= 0"])
      s.add_development_dependency(%q<RedCloth>, [">= 0"])
      s.add_development_dependency(%q<gtksourceview2>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, ["~> 2.11"])
      s.add_development_dependency(%q<hoe-gemspec>, ["~> 1.0"])
      s.add_development_dependency(%q<hoe-bundler>, ["~> 1.1"])
      s.add_development_dependency(%q<minitest>, ["~> 2.0"])
      s.add_development_dependency(%q<hoe>, ["~> 2.12"])
    else
      s.add_dependency(%q<distribution>, [">= 0.4.0"])
      s.add_dependency(%q<green_shoes>, [">= 1.0.282"])
      s.add_dependency(%q<statsample>, [">= 1.1.0"])
      s.add_dependency(%q<integration>, [">= 0"])
      s.add_dependency(%q<minimization>, [">= 0"])
      s.add_dependency(%q<gsl>, ["~> 1.14.5"])
      s.add_dependency(%q<rsvg2>, ["~> 1.0.0"])
      s.add_dependency(%q<rubyvis>, [">= 0.4.0"])
      s.add_dependency(%q<hoe>, ["~> 2.12"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 2.0"])
      s.add_dependency(%q<haml>, [">= 0"])
      s.add_dependency(%q<coderay>, [">= 0"])
      s.add_dependency(%q<nokogiri>, [">= 0"])
      s.add_dependency(%q<RedCloth>, [">= 0"])
      s.add_dependency(%q<gtksourceview2>, [">= 0"])
      s.add_dependency(%q<shoulda>, ["~> 2.11"])
      s.add_dependency(%q<hoe-gemspec>, ["~> 1.0"])
      s.add_dependency(%q<hoe-bundler>, ["~> 1.1"])
      s.add_dependency(%q<minitest>, ["~> 2.0"])
      s.add_dependency(%q<hoe>, ["~> 2.12"])
    end
  else
    s.add_dependency(%q<distribution>, [">= 0.4.0"])
    s.add_dependency(%q<green_shoes>, [">= 1.0.282"])
    s.add_dependency(%q<statsample>, [">= 1.1.0"])
    s.add_dependency(%q<integration>, [">= 0"])
    s.add_dependency(%q<minimization>, [">= 0"])
    s.add_dependency(%q<gsl>, ["~> 1.14.5"])
    s.add_dependency(%q<rsvg2>, ["~> 1.0.0"])
    s.add_dependency(%q<rubyvis>, [">= 0.4.0"])
    s.add_dependency(%q<hoe>, ["~> 2.12"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 2.0"])
    s.add_dependency(%q<haml>, [">= 0"])
    s.add_dependency(%q<coderay>, [">= 0"])
    s.add_dependency(%q<nokogiri>, [">= 0"])
    s.add_dependency(%q<RedCloth>, [">= 0"])
    s.add_dependency(%q<gtksourceview2>, [">= 0"])
    s.add_dependency(%q<shoulda>, ["~> 2.11"])
    s.add_dependency(%q<hoe-gemspec>, ["~> 1.0"])
    s.add_dependency(%q<hoe-bundler>, ["~> 1.1"])
    s.add_dependency(%q<minitest>, ["~> 2.0"])
    s.add_dependency(%q<hoe>, ["~> 2.12"])
  end
end
