# Copyright (c) 2010 - 2011, Ruby Science Foundation
# All rights reserved.
#
# Please see LICENSE.txt for additional copyright notices.
#
# By contributing source code to SciRuby, you agree to be bound by our Contributor
# Agreement:
#
# * https://github.com/SciRuby/sciruby/wiki/Contributor-Agreement
#
# === analysis.rb
#


require 'sciruby/analysis/suite'
require 'sciruby/analysis/suite_report_builder'

module SciRuby
  # DSL to run a statistical analysis without hassle.
  # * Shortcut methods to avoid having to use complete namespaces, many based on R.
  # * Attach/detach vectors to workspace, as with R
  #
  # === Example
  #
  #  an1 = Statsample::Analysis.store(:first) do
  #    # Load excel file with x,y,z vectors
  #    ds = excel('data.xls')
  #    # See variables on ds dataset
  #    names(ds)
  #    # Attach the vectors to workspace, like R
  #    attach(ds)
  #    # vector 'x' is attached to workspace like a method,
  #    # so you can use like any variable
  #    mean,sd = x.mean, x.sd
  #    # Shameless R robbery
  #    a = c( 1:10)
  #    b = c(21:30)
  #    summary(cor(ds)) # Call summary method on correlation matrix
  #  end
  #  # You can run the analysis by its name
  #  Statsample::Analysis.run(:first)
  #  # or using the returned variables
  #  an1.run
  #  # You can also generate a report using ReportBuilder.
  #  # .summary() method call 'report_building' on the object,
  #  # instead of calling text summary
  #  an1.generate("report.html")
  #
  module Analysis
    @@stored_analyses={}
    @@last_analysis=nil
    def self.clear_analysis
      @@stored_analyses.clear
    end
    def self.stored_analyses
      @@stored_analyses
    end
    def self.last
      @@stored_analyses[@@last_analysis]
    end
    def self.store(name, opts=Hash.new,&block)
      raise "You should provide a block" if !block
      @@last_analysis=name
      opts={:name=>name}.merge(opts)
      @@stored_analyses[name]=Suite.new(opts,&block)
    end
    # Run analysis +*args+
    # Without arguments, run all stored analyses
    # Only 'echo' will be printed to screen.
    def self.run(*args)
      args=stored_analyses.keys if args.size==0
      raise "Analysis #{args} doesn't exists" if (args - stored_analyses.keys).size>0
      args.each do |name|
        stored_analyses[name].run
      end
    end

    # Add analysis +*args+ to a ReportBuilder object.
    # Without arguments, add all stored analyses.
    # Each analysis is wrapped inside a ReportBuilder::Section object.
    # This is the method used by +save+ and +to_text+.
    def self.add_to_reportbuilder(rb, *args)
      args=stored_analyses.keys if args.size==0
      raise "Analysis #{name} doesn't exists" if (args - stored_analyses.keys).size>0
      args.each do |name|
        section=ReportBuilder::Section.new(:name=>stored_analyses[name].name)
        rb_an=stored_analyses[name].add_to_reportbuilder(section)
        rb.add(section)
        rb_an.run
      end
    end

    # Save the analysis to a file.
    # Without arguments, adds all stored analyses.
    def self.save(filename, *args)
      rb=ReportBuilder.new(:name=>filename)
      add_to_reportbuilder(rb, *args)
      rb.save(filename)
    end

    # Run analysis and return as string.
    # Only 'echo' will be printed to screen.
    # Without arguments, add all stored analyses.
    def self.to_text(*args)
      rb=ReportBuilder.new(:name=>"Analysis #{Time.now}")
      add_to_reportbuilder(rb, *args)
      rb.to_text
    end

    # Run analysis and print to screen all echo and summary callings
    def self.run_batch(*args)
      puts to_text(*args)
    end
  end
end