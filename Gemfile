load File.expand_path(File.join(__FILE__, '..', 'scripts', 'helper.rb'))

source 'https://rubygems.org'

Helper.sciruby_gems(true).each do |g|
  gem(g[:name], *g[:version])
end

# development dependencies
gem 'minitest'
gem 'rake'
gem 'bundler'
gem 'slim'
