require 'assert/options'
require 'assert/view/renderer'

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

    # the Renderer defines the hooks and callbacks needed for the runner to
    # work with the view.  It provides:
    # * 'render': called by the runner to render the view
    # * 'self.helper': used to provide helper mixins to the renderer template
    include Renderer

    attr_accessor :suite, :output_io, :runtime_result_callback

    def initialize(output_io, suite=Assert.suite)
      self.suite = suite
      self.output_io = output_io
    end

    def view
      self
    end



    # TODO: look for files in the .assert dir
    # TODO: allow option for specifying which template to use
    # TODO: test
    def template_file
      File.expand_path("./templates/#{self.options.template}.rb", File.dirname(__FILE__))
    end



    # called by the view template
    # store off any result_callback
    # call the runner callback to actually run the tests
    def run_tests(runner_callback, &result_callback)
      self.runtime_result_callback = result_callback
      runner_callback.call if runner_callback
    end

    # callback used by the runner to notify the view of any new results
    # pipes the runtime result to any result callback block
    def handle_runtime_result(result)
      self.runtime_result_callback.call(result) if self.runtime_result_callback
    end

    # get the formatted suite run time
    def run_time(format='%.6f')
      format % self.suite.run_time
    end

    def runner_seed
      self.suite.runner_seed
    end

    def count(type)
      self.suite.count(type)
    end

    # TODO: test
    def tests?
      self.count(:tests) > 0
    end

    def all_passed?
      self.count(:passed) == self.count(:results)
    end

    # return a list of result symbols that have actually occurred
    def ocurring_result_types
      @result_types ||= [
        :passed, :failed, :ignored, :skipped, :errored
      ].select { |result_sym| self.count(result_sym) > 0 }
    end

    # print a result summary message for a given result type
    def result_summary_msg(result_type)
      if result_type == :passed && self.all_passed?
        self.all_passed_result_summary_msg
      else
        "#{self.count(result_type)} #{result_type.to_s}"
      end
    end

    # generate an appropriate result summary msg for all tests passing
    def all_passed_result_summary_msg
      if self.count(:results) < 1
        "uhh..."
      elsif self.count(:results) == 1
        "it passed"
      else
        "all passed"
      end
    end

    # generate a comma-seperated sentence fragment given a list of things
    def to_sentence(things)
      if things.size <= 2
        things.join(things.size == 2 ? ' and ' : '')
      else
        [things[0..-2].join(", "), things.last].join(", and ")
      end
    end

  end

end
