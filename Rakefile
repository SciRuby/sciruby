#!/usr/bin/ruby
# -*- ruby -*-
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)+'/lib/')

require 'rubygems'
require 'rdoc/task'
require 'sciruby'
require 'hoe'

# Hoe.plugin :compiler
# Hoe.plugin :cucumberfeatures
# Hoe.plugin :gem_prelude_sucks
Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :bundler
# Hoe.plugin :inline
# Hoe.plugin :manifest
# Hoe.plugin :newgem
# Hoe.plugin :racc
# Hoe.plugin :rubyforge
# Hoe.plugin :website

desc "Ruby Lint"
task :lint do
  executable=Config::CONFIG['RUBY_INSTALL_NAME']
  Dir.glob("lib/**/*.rb") {|f|
    if !system %{#{executable} -w -c "#{f}"}
        puts "Error on: #{f}"
    end
  }
end

desc "Open an irb session preloaded with sciruby"
task :console do
  sh "irb -rubygems -I lib -r sciruby.rb"
end

desc "Start the plotter without the console"
task :plotter, [:script] => [] do |t,args|
  if args.script.empty?
    raise ArgumentError, "Need a script, e.g.: rake plotter[script.rb]"
  else
    sh "ruby -rubygems -I lib -r sciruby.rb -e 'SciRuby::Plotter.new(\"#{args.script}\")'"
  end
end

desc "Start the plotter without the console"
task :editor do
  sh "ruby -rubygems -I lib -r sciruby.rb -e 'SciRuby::Editor.new'"
end

task :release do
  system %{git push origin master}
end

h = Hoe.spec 'sciruby' do
  self.version = SciRuby::VERSION
  self.require_ruby_version ">=1.9"
  self.developer('SciRuby Development Team', 'sciruby-dev@googlegroups.com')
  self.extra_deps = {'distribution' => ">=0.4.0",
                     'green_shoes' => ">=1.0.282",
                     'statsample' => ">=1.1.0",
                     'integration' => ">= 0",
                     'minimization' => ">= 0",
                     'gsl' => "~> 1.14.5",
                     'rsvg2' => '~> 1.0.0',
                     'rubyvis' => '>=0.4.0'        }.to_a


  self.extra_dev_deps = {'hoe' => "~> 2.12",
                         'rdoc' => ">=0",
                         'rspec' => ">=2.0",
                         'haml' => ">=0", # for Rubyvis
                         'coderay' => ">=0", # for Rubyvis
                         'nokogiri' => ">=0", # for Rubyvis
                         'RedCloth' => ">=0", # for Rubyvis
                         'gtksourceview2' => ">=0", # for editor
                         'shoulda' => "~> 2.11",
                         'hoe-gemspec' => "~> 1.0",
                         'hoe-bundler' => "~> 1.1",
                         'minitest' => "~> 2.0" }.to_a

  #self.executables = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }

  self.post_install_message = <<-EOF
***********************************************************
Welcome to SciRuby: Tools for Scientific Computing in Ruby!

                     *** WARNING ***
Please be aware that SciRuby is in ALPHA status. If you're
thinking of using SciRuby to write mission critical code,
such as for driving a car or flying a space shuttle, you
may wish to choose other software (for now).

In order to leverage the GUI features, you will need to
install gtk2 and optionally gtksourceview2:

  $ gem install gtk2 gtksourceview2

You will probably first need to install the headers for
a number of required packages. In Ubuntu, use:

  $ sudo apt-get install libgtk2.0-dev libgtksourceview2-dev \\
      librsvg2-dev libcairo2-dev

If you have trouble with Green Shoes, you should look at
the Green Shoes wiki:

* http://github.com/ashbb/green_shoes/wiki

For Mac OSX Green Shoes:

* https://github.com/ashbb/green_shoes/wiki/Building-Green-Shoes-on-OSX

More explicit instructions for SciRuby should be available
at our website, sciruby.com, or through our mailing list
(which can also be found on our website).

Thanks for installing SciRuby! Happy hypothesis testing!

***********************************************************
  EOF

  self.need_rdoc = false

end

RDoc::Task.new(:docs) do |rd|
  rd.main = h.readme_file
  rd.options << '-d' if (`which dot` =~ /\/dot/) unless
    ENV['NODOT'] || Hoe::WINDOZE
  rd.rdoc_dir = 'doc'

  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_files += h.spec.extra_rdoc_files
  rd.rdoc_files.reject! {|f| f=="Manifest.txt"}
  title = h.spec.rdoc_options.grep(/^(-t|--title)=?$/).first
  if title then
    rd.options << title

    unless title =~ /\=/ then # for ['-t', 'title here']
    title_index = spec.rdoc_options.index(title)
    rd.options << spec.rdoc_options[title_index + 1]
    end
  else
    title = "#{h.name}-#{h.version} Documentation"
    title = "#{h.rubyforge_name}'s " + title if h.rubyforge_name != h.name
    rd.options << '--title' << title
  end
end

desc 'Publish rdocs with analytics support'
task :publish_docs => [:clean, :docs] do
  ruby %{aggregate_adsense_to_doc.rb}
  path = File.expand_path("~/.rubyforge/user-config.yml")
  config = YAML.load(File.read(path))
  host = "#{config["username"]}@rubyforge.org"

  remote_dir = "/var/www/gforge-projects/#{h.rubyforge_name}/#{h.remote_rdoc_dir
  }"
  local_dir = h.local_rdoc_dir
  Dir.glob(local_dir+"/**/*") {|file|
    sh %{chmod 755 #{file}}
  }
  sh %{rsync #{h.rsync_args} #{local_dir}/ #{host}:#{remote_dir}}
end

require 'rspec/core/rake_task'
namespace :spec do
  desc "Run all specs"
  RSpec::Core::RakeTask.new
  # options in .rspec in package root
end


# vim: syntax=ruby
