# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "sciruby"
  s.version = "0.1.3.20111102203144"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["SciRuby Development Team"]
  s.date = "2011-11-03"
  s.description = "Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and visualization libraries in Ruby. We are not the first with this idea, but we are trying to bring it to life."
  s.email = ["sciruby-dev@googlegroups.com"]
  s.executables = ["sciruby-plotter"]
  s.extra_rdoc_files = ["History.txt", "Manifest.txt"]
  s.files = [".autotest", "History.txt", "Manifest.txt", "readme.md", "Rakefile", "lib/sciruby.rb", "lib/sciruby/validation.rb", "lib/sciruby/recommend.rb", "lib/sciruby/plotter.rb", "lib/sciruby/editor.rb", "lib/sciruby/config.rb", "lib/sciruby/analysis.rb", "lib/sciruby/analysis/suite.rb", "lib/sciruby/analysis/suite_report_builder.rb", "lib/sciruby/data.rb", "lib/sciruby/data/guardian.rb", "lib/sciruby/data/r.rb", "lib/sciruby/data/r/base.rb", "lib/sciruby/data/r/data_frame.rb", "lib/sciruby/data/r/grouped_data.rb", "lib/sciruby/data/r/list.rb", "lib/sciruby/data/r/multi_time_series.rb", "lib/sciruby/data/r/r_matrix.rb", "lib/sciruby/data/r/time_series.rb", "lib/sciruby/data/r/time_series_base.rb", "lib/sciruby/data/r/vector.rb", "lib/ext/shoes.rb", "lib/ext/csv.rb", "lib/ext/string.rb", "bin/sciruby-plotter", "static/sciruby-icon.png", "test/test_recommend.rb", "test/helpers_tests.rb", "data/r/man/ability.cov.Rd", "data/r/man/airmiles.Rd", "data/r/man/AirPassengers.Rd", "data/r/man/airquality.Rd", "data/r/man/anscombe.Rd", "data/r/man/attenu.Rd", "data/r/man/attitude.Rd", "data/r/man/austres.Rd", "data/r/man/beavers.Rd", "data/r/man/BJsales.Rd", "data/r/man/BOD.Rd", "data/r/man/cars.Rd", "data/r/man/ChickWeight.Rd", "data/r/man/chickwts.Rd", "data/r/man/co2.Rd", "data/r/man/crimtab.Rd", "data/r/man/datasets-package.Rd", "data/r/man/discoveries.Rd", "data/r/man/DNase.Rd", "data/r/man/esoph.Rd", "data/r/man/eurodist.Rd", "data/r/man/euro.Rd", "data/r/man/EuStockMarkets.Rd", "data/r/man/faithful.Rd", "data/r/man/Formaldehyde.Rd", "data/r/man/freeny.Rd", "data/r/man/HairEyeColor.Rd", "data/r/man/Harman23.cor.Rd", "data/r/man/Harman74.cor.Rd", "data/r/man/Indometh.Rd", "data/r/man/infert.Rd", "data/r/man/InsectSprays.Rd", "data/r/man/iris.Rd", "data/r/man/islands.Rd", "data/r/man/JohnsonJohnson.Rd", "data/r/man/LakeHuron.Rd", "data/r/man/lh.Rd", "data/r/man/LifeCycleSavings.Rd", "data/r/man/Loblolly.Rd", "data/r/man/longley.Rd", "data/r/man/lynx.Rd", "data/r/man/morley.Rd", "data/r/man/mtcars.Rd", "data/r/man/nhtemp.Rd", "data/r/man/Nile.Rd", "data/r/man/nottem.Rd", "data/r/man/occupationalStatus.Rd", "data/r/man/Orange.Rd", "data/r/man/OrchardSprays.Rd", "data/r/man/PlantGrowth.Rd", "data/r/man/precip.Rd", "data/r/man/presidents.Rd", "data/r/man/pressure.Rd", "data/r/man/Puromycin.Rd", "data/r/man/quakes.Rd", "data/r/man/randu.Rd", "data/r/man/rivers.Rd", "data/r/man/rock.Rd", "data/r/man/sleep.Rd", "data/r/man/stackloss.Rd", "data/r/man/state.Rd", "data/r/man/sunspot.month.Rd", "data/r/man/sunspots.Rd", "data/r/man/sunspot.year.Rd", "data/r/man/swiss.Rd", "data/r/man/Theoph.Rd", "data/r/man/Titanic.Rd", "data/r/man/ToothGrowth.Rd", "data/r/man/treering.Rd", "data/r/man/trees.Rd", "data/r/man/UCBAdmissions.Rd", "data/r/man/UKDriverDeaths.Rd", "data/r/man/UKgas.Rd", "data/r/man/UKLungDeaths.Rd", "data/r/man/USAccDeaths.Rd", "data/r/man/USArrests.Rd", "data/r/man/USJudgeRatings.Rd", "data/r/man/USPersonalExpenditure.Rd", "data/r/man/uspop.Rd", "data/r/man/VADeaths.Rd", "data/r/man/volcano.Rd", "data/r/man/warpbreaks.Rd", "data/r/man/women.Rd", "data/r/man/WorldPhones.Rd", "data/r/man/WWWusage.Rd", "data/r/man/zCO2.Rd", ".gemtest"]
  s.homepage = "http://sciruby.com"
  s.post_install_message = "***********************************************************\nWelcome to SciRuby: Tools for Scientific Computing in Ruby!\n\n                     *** WARNING ***\nPlease be aware that SciRuby is in ALPHA status. If you're\nthinking of using SciRuby to write mission critical code,\nsuch as for driving a car or flying a space shuttle, you\nmay wish to choose other software (for now).\n\nIn order to leverage the GUI features, you will need to\ninstall gtk2 and optionally gtksourceview2:\n\n  $ gem install gtk2 gtksourceview2\n\nYou will probably first need to install the headers for\na number of required packages. In Ubuntu, use:\n\n  $ sudo apt-get install libgtk2.0-dev libgtksourceview2-dev \\\n      librsvg2-dev libcairo2-dev\n\nIf you have trouble with Green Shoes, you should look at\nthe Green Shoes wiki:\n\n* http://github.com/ashbb/green_shoes/wiki\n\nFor Mac OSX Green Shoes:\n\n* https://github.com/ashbb/green_shoes/wiki/Building-Green-Shoes-on-OSX\n\nMore explicit instructions for SciRuby should be available\nat our website, sciruby.com, or through our mailing list\n(which can also be found on our website).\n\nThanks for installing SciRuby! Happy hypothesis testing!\n\n***********************************************************\n"
  s.rdoc_options = ["--main", "README.rdoc"]
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
      s.add_runtime_dependency(%q<simpler>, [">= 0.1.0"])
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
      s.add_dependency(%q<simpler>, [">= 0.1.0"])
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
    s.add_dependency(%q<simpler>, [">= 0.1.0"])
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
