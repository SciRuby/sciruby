# SciRuby

* http://sciruby.com
* http://github.com/SciRuby/sciruby

## Description

Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and visualization libraries in Ruby.

We are not the first with this idea, but we are trying to bring it to life.

[![Click here to lend your support to SciRuby and make a donation at pledgie.com!](https://www.pledgie.com/campaigns/15783.png?skin_name=chrome)](http://www.pledgie.com/campaigns/15783)

## Warning!

Please be aware that SciRuby is in ALPHA status. If you're thinking of using SciRuby to write mission critical code, such as for driving a car or flying a space shuttle, you may wish to choose other software (for now).

## Planned Features

* Numarray: [Narray](http://narray.rubyforge.org/) rewrite.
* SciRuby::Analysis - domain-specific language (DSL) for hassle-free statistical analysis (originally from [Statsample](http://github.com/clbustos/statsample))

## Current Features
* SciRuby::Plotter - visualization GUI for updating plots as scripts are modified
* SciRuby::Editor - code editor for modifying rubyvis plot scripts
* [Rubyvis](http://rubyvis.rubyforge.org) - [Protovis](http://mbostock.github.com/protovis/)-like plotting in Ruby
* [Statsample](https://github.com/clbustos/statsample) - a suite for basic and advanced statistics in Ruby
* [Minimization](https://github.com/clbustos/minimization) algorithms in pure Ruby and using GSL
* Numeric [integration](https://github.com/clbustos/integration) algorithms

## Synopsis

FIX (code sample of usage)

## Requirements

* statsample (and optionally statsample-optimization)
* distribution
* rubyvis
* narray
* minimization
* integration
* green_shoes

## Installation

    gem install sciruby

You'll also want to make sure you install the headers for the GUI. If you're using Ubuntu:

    sudo apt-get install libgtk2.0-dev libgtksourceview2-dev librsvg2-dev libcairo2-dev

Instructions for installing these for OSX are available through the [Green Shoes wiki](https://github.com/ashbb/green_shoes/wiki/Building-Green-Shoes-on-OSX).

You can also optionally get rb-gsl, statistics2, and other useful architecture-specific packages using

    gem install statsample-optimization

## Developers

After checking out the source, run:

    $ rake newb
    $ bundle install

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## License

SciRuby is licensed under the GNU General Public License, v3.

## Donations

[![Click here to lend your support to SciRuby and make a donation at pledgie.com!](https://www.pledgie.com/campaigns/15783.png?skin_name=chrome)](http://www.pledgie.com/campaigns/15783)
