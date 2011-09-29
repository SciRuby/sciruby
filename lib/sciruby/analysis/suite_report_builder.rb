module SciRuby
  module Analysis
    class SuiteReportBuilder < Suite
      attr_accessor :rb
      def initialize(opts=Hash.new,&block)
        if !opts.is_a? Hash
          opts={:name=>opts}
        end
        super(opts,&block)
        @rb=opts[:rb] || ReportBuilder.new(:name=>name)
      end
      def generate(filename)
        run if @block
        @rb.save(filename)
      end
      def to_text
        run if @block
        @rb.to_text
      end
      def summary(o)
        @rb.add(o)
      end
      def desc(d)
        @rb.add(d)
      end
      def echo(*args)
        args.each do |a|
          @rb.add(a)
        end
      end

      def boxplot(*args)
        @rb.add(old_boxplot(*args))
      end
      def histogram(*args)
        @rb.add(old_histogram(*args))
      end
      def boxplot(*args)
        @rb.add(old_boxplot(*args))
      end

    end
  end
end