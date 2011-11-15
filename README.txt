= sciruby

home    :: http://sciruby.com
github  :: http://github.com/SciRuby/sciruby

== DESCRIPTION:

Ruby has for some time had no equivalent to the beautifully constructed numpy, scipy, and matplotlib libraries for Python. We believe that the time for a Ruby science and visualization package has come and gone. Sometimes when a solution of sugar and water becomes super-saturated, from it precipitates a pure, delicious, and diabetes-inducing crystal of sweetness, induced by no more than the tap of a finger. So it is, we believe, with the need for numeric and visualization libraries in Ruby.

We are not the first with this idea, but we are trying to bring it to life.

Support us at Pledgie.com: http://www.pledgie.com/campaigns/15783

=== WARNING:

Please be aware that SciRuby is in PRE-ALPHA status. If you're thinking of using SciRuby to write mission critical code, such as for driving a car or flying a space shuttle, you may wish to choose other software (for now).

== PLANNED FEATURES:

* Numarray: <a href="http://narray.rubyforge.org/">Narray</a> rewrite, including sparse matrices.

== CURRENT FEATURES:

* SciRuby::Plotter - visualization GUI for updating plots as scripts are modified
* SciRuby::Editor - code editor for modifying rubyvis plot scripts
* <a href="http://rubyvis.rubyforge.org">Rubyvis</a> - <a href="http://mbostock.github.com/protovis/">Protovis</a>-like plotting in Ruby
* <a href="https://github.com/clbustos/statsample">Statsample</a> - a suite for basic and advanced statistics in Ruby
* SciRuby::Analysis - domain-specific language (DSL) for hassle-free statistical analysis (originally from <a href="http://github.com/clbustos/statsample">Statsample</a>)
* <a href="https://github.com/clbustos/minimization">Minimization</a> algorithms in pure Ruby and using GSL
* Numeric <a href="https://github.com/clbustos/integration">integration</a> algorithms

== SYNOPSIS:

From the command line,

    sciruby-plotter my_plot.rb

Or, inside a Ruby shell,

    $ require 'sciruby'

== REQUIREMENTS:

* statsample (and optionally statsample-optimization)
* distribution
* rubyvis
* narray
* minimization
* integration
* green_shoes

== INSTALLATION:

    gem install sciruby

You'll also want to make sure you install the headers for the GUI. If you're using Ubuntu:

    sudo apt-get install libgtk2.0-dev libgtksourceview2.0-dev librsvg2-dev libcairo2-dev

You can also optionally get rb-gsl, statistics2, and other useful architecture-specific packages using

    gem install statsample-optimization

More detailed installation instructions are available at sciruby.com: http://sciruby.com/docs#installation

## DEVELOPERS:

After checking out the source, run:

    $ bundle exec rake newb
    $ bundle install

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

NOTE: Don't despair if `rake newb` doesn't work for you. We're still working out the kinks.

## LICENSE:

SciRuby is licensed under the GNU General Public License, v3.

## DONATIONS:

<a href="http://www.pledgie.com/campaigns/15783"><img src="https://www.pledgie.com/campaigns/15783.png?skin_name=chrome" alt="Click here to lend your support to SciRuby and make a donation at pledgie.com!" /></a>
