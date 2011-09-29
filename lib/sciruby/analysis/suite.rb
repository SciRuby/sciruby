require "statsample"

module SciRuby
  module Analysis
    class Suite
      include ::Statsample::Shorthand
      attr_accessor :output
      attr_accessor :name
      attr_reader :block
      def initialize(opts=Hash.new(), &block)
        if !opts.is_a? Hash
          opts={:name=>opts}
        end

        @block=block
        @name=opts[:name] || "Analysis #{Time.now}"
        @attached=[]
        @output=opts[:output] || ::STDOUT
      end
      # Run the analysis, putting output on
      def run
         @block.arity<1 ? instance_eval(&@block) : @block.call(self)
      end
      # Provides a description of the procedure. Only appears as a commentary on
      # SuiteReportBuilder outputs
      def desc(d)
        @output.puts("Description:")
        @output.puts("  #{d}")
      end
      def echo(*args)
        @output.puts(*args)
      end
      def summary(obj)
        obj.summary
      end
      def add_to_reportbuilder(rb)
        SuiteReportBuilder.new({:name=>name, :rb=>rb}, &block)
      end

      def generate(filename)
        ar=SuiteReportBuilder.new({:name=>name}, &block)
        ar.generate(filename)
      end
      def to_text
        ar=SuiteReportBuilder.new({:name=>name}, &block)
        ar.to_text
      end

      def attach(ds)
        @attached.push(ds)
      end
      def detach(ds=nil)
        if ds.nil?
          @attached.pop
        else
          @attached.delete(ds)
        end
      end
      alias :old_boxplot :boxplot
      alias :old_histogram :histogram
      alias :old_scatterplot :scatterplot

      def show_svg(svg)
        require 'tmpdir'
        fn=Dir.tmpdir+"/image_#{Time.now.to_f}.svg"
        File.open(fn,"w") {|fp| fp.write svg}
        `xdg-open '#{fn}'`
      end
      def boxplot(*args)
        show_svg(old_boxplot(*args).to_svg)
      end
      def histogram(*args)
        show_svg(old_histogram(*args).to_svg)
      end
      def scatterplot(*args)
        show_svg(old_scatterplot(*args).to_svg)
      end

      def method_missing(name, *args,&block)
        @attached.reverse.each do |ds|
          return ds[name.to_s] if ds.fields.include? (name.to_s)
        end
        raise "Method #{name} doesn't exists"
      end
    end
  end
end