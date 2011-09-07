Gem::Specification.new do |s|
  s.name = 'sciruby'
  s.version = '0.1.0'
  
  s.author = 'SciRuby'
  s.email = 'john.woods@marcottelab.org'
  s.homepage = 'http://www.sciruby.com'
  s.rubyforge_project = 'sciruby'
  
  s.summary = 'Tools for scientific computation in Ruby'
  s.description = <<-EOF
Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and visualization libraries in Ruby.

We are not the first with this idea, but we are trying to bring it to life.

At this point, SciRuby has not much to offer. But if you install this gem, you'll get as dependencies all of the libraries that we plan to incorporate into SciRuby.
  EOF
  
  s.platform = Gem::Platform::RUBY
  
  s.files = [
    'lib/sciruby.rb',
    'lib/sciruby/recommend.rb'
    ]
  
  s.require_path = 'lib'
end