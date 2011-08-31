require 'assert/options'

module Assert::View

  class Base
    include Assert::Options
    options do
      default_passed_abbrev   '.'
      default_failed_abbrev   'F'
      default_ignored_abbrev  'I'
      default_skipped_abbrev  'S'
      default_errored_abbrev  'E'
    end

    attr_reader :suite

    def initialize(output_io, suite=Assert.suite)
      @suite = suite
      @out = output_io
    end

    # override this to define how a view calls the runner and renders its results
    def render(*args, &runner)
    end

    def handle_runtime_result(result)
    end

    protected

    def io_puts(msg, opts={})
      @out.puts(io_msg(msg, opts={}))
    end

    def io_print(msg, opts={})
      @out.print(io_msg(msg, opts={}))
    end

    def run_time(format='%.6f')
      format % @suite.run_time
    end

    def runner_seed
      @suite.runner_seed
    end

    def count(type)
      @suite.count(type)
    end

    private

    def io_msg(msg, opts={})
      if msg.kind_of?(::Symbol) && self.respond_to?(msg)
        self.send(msg).to_s
      else
        msg.to_s
      end
    end

  end

end
