#!/usr/bin/ruby
# -*- ruby -*-
# -*- coding: utf-8 -*-
$:.unshift(File.dirname(__FILE__)+'/lib/')

require 'rubygems'
require 'sciruby'
require 'hoe'

# Hoe.plugin :compiler
# Hoe.plugin :cucumberfeatures
# Hoe.plugin :gem_prelude_sucks
Hoe.plugin :git
# Hoe.plugin :inline
# Hoe.plugin :inline
# Hoe.plugin :manifest
# Hoe.plugin :newgem
# Hoe.plugin :racc
# Hoe.plugin :rubyforge
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

task :release do
  system %{git push origin master}
end

h = Hoe.spec 'sciruby' do
  self.version = SciRuby::VERSION
  self.developer('SciRuby Development Team', 'sciruby-dev@googlegroups.com')
  self.extra_deps = {'distribution' => "~> 0.3",
                     # 'statsample' => "~> 0",
                     'gsl' => "~> 1.14.5"         }.to_a

  self.extra_dev_deps = {'hoe' => "~> 0",
                         'shoulda' => "~> 0",
                         'minitest' => "~> 2.0" }.to_a

  # self.rubyforge_name = 'scirubyx' # if different than 'sciruby'
end

Rake::RDocTask.new(:docs) do |rd|
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

# vim: syntax=ruby
