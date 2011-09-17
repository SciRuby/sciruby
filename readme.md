# SciRuby

[https://github.com/SciRuby/sciruby](https://github.com/SciRuby/sciruby)

<a href="http://www.pledgie.com/campaigns/15783"><img alt="Click here to lend your support to SciRuby and make a donation at pledgie.com" src="http://www.pledgie.com/campaigns/15783.png?skin_name=chrome" border="0" /></a>

## Description

Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and visualization libraries in Ruby.

We are not the first with this idea, but we are trying to bring it to life.

At this point, SciRuby has not much to offer. But if you install this gem, you'll get as dependencies all of the libraries that we plan to incorporate into SciRuby.

## Planned Features

* Visualization (web by way of protovis, otherwise with rubyvis)
* Statistical methods and distributions
* Numeric computation

## Current Features

* SciRuby::Recommend::SetDistance - expert recommendations based on sets of binary associations.

## Synopsis

FIX (code sample of usage)

## Requirements

* distribution (and preferably statistics2 or gsl)
* statsample
* rubyvis or protovis
* narray

## Installation

    (sudo) gem install sciruby

## Developers

After checking out the source, run:

    $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## License

SciRuby is licensed under the GNU General Public License, v3.
