require 'assert/options'

module Assert::View

  # this module is mixed in to the Assert::View::Base class
  # it use Undies to define and render view templates
  module Renderer
    require 'undies'

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    # define rendering template class to use for rendering
    # need to overwrite the '_' and '__' meths to add trailing newlines
    # b/c streaming output doesn't add any whitespace
    class Template < ::Undies::Template

      def _(data="", nl=true);  super(data.to_s + (nl ? "\n" : "")); end
      def __(data="", nl=true); super(data.to_s + (nl ? "\n" : "")); end

    end

    # this method is required by assert and is called by the test runner
    # use Undies to render the template
    # using the view's template file
    # streaming to the view's output io
    # passing in the view itself and any runner_callback as locals
    def render(*args, &runner_callback)
      locals = {
        :view => self,
        :runner => runner_callback
      }
      Template.new(self.output_io, locals, &self.class.template)
    end

    module ClassMethods

      # make any helper methods available to the template
      def helper(helper_klass)
        Template.send(:include, helper_klass)
      end

    end

  end


  class Base

    include Assert::Options
    options do
      default_view_name
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

    # set the view's template by passing a block, get by calling w/ no args
    def self.template(&block)
      if block
        @template = block
      else
        @template
      end
    end

    attr_accessor :suite, :output_io, :runtime_result_callback

    def initialize(output_io, suite=Assert.suite)
      self.suite = suite
      self.output_io = output_io
    end

    def view
      self
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
