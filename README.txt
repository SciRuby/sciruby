= SciRuby

* http://github.com/sciruby/sciruby

== DESCRIPTION:

Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for
Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a
solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing
crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and
visualization libraries in Ruby.

We are not the first with this idea, but we are trying to bring it to life.

At this point, SciRuby has not much to offer. But if you install this gem, you'll get as dependencies all of the
libraries that we plan to incorporate into SciRuby.

== ULTIMATE FEATURES:

* Visualization (web by way of protovis, otherwise with rubyvis)
* Statistical methods and distributions
* Numeric computation

== CURRENT FEATURES:

* SciRuby::Recommend::SetDistance - expert recommendations based on sets of binary associations.

== SYNOPSIS:

  FIX (code sample of usage)

== REQUIREMENTS:

* distribution (and preferably statistics2 or gsl)
* statsample
* rubyvis or protovis
* narray

== INSTALL:

* sudo gem install sciruby

== DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

== LICENSE:

This will be GPLv2 or GPLv3. For now, see GPLv2.