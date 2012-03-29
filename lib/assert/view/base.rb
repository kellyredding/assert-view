require 'assert/result'
require 'assert/options'

module Assert::View

  # this module is mixed in to the Assert::View::Base class
  module Renderer

    def self.included(receiver)
      receiver.send(:extend, ClassMethods)
    end

    # define rendering template class to use for rendering
    # need to overwrite the '_' and '__' meths to add trailing newlines
    # b/c streaming output doesn't add any whitespace
    class Template

      def initialize(*args)
        # setup a node stack with the given output obj
        @io = args.pop

        # apply any given data to template scope
        data = args.last.kind_of?(::Hash) ? args.pop : {}
        if (data.keys.map(&:to_s) & self.public_methods.map(&:to_s)).size > 0
          raise ArgumentError, "data conflicts with template public methods."
        end
        metaclass = class << self; self; end
        data.each {|key, value| metaclass.class_eval { define_method(key){value} }}

        # setup a source stack with the given source
        @source = args.pop || Proc.new {}
        instance_eval(&@source)
      end

      def _(data="", nl=true);  @io << (data.to_s + (nl ? "\n" : "")); end
      def __(data="", nl=true); @io << (data.to_s + (nl ? "\n" : "")); end

    end

    # this method is required by assert and is called by the test runner
    # render the template
    # using the view's template file
    # streaming to the view's output io
    # passing in the view itself and any runner_callback as locals
    def render(*args, &runner_callback)
      Template.new(self.class.template, {
        :view => self,
        :runner => runner_callback
      }, self.output_io)
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
      default_pass_abbrev   '.'
      default_fail_abbrev   'F'
      default_ignore_abbrev 'I'
      default_skip_abbrev   'S'
      default_error_abbrev  'E'
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
      self.output_io = output_io
      self.suite     = suite
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

    def all_pass?
      self.count(:pass) == self.count(:results)
    end

    # get a uniq list of contexts for the test suite
    def suite_contexts
      @suite_contexts ||= self.suite.tests.inject([]) do |contexts, test|
        contexts << test.context_info.klass
      end.uniq
    end

    def ordered_suite_contexts
      self.suite_contexts.sort{|a,b| a.to_s <=> b.to_s}
    end

    # get a uniq list of files containing contexts for the test suite
    def suite_files
      @suite_files ||= self.suite.tests.inject([]) do |files, test|
        files << test.context_info.file
      end.uniq
    end

    def ordered_suite_files
      self.suite_files.sort{|a,b| a.to_s <=> b.to_s}
    end

    # get all the results that have details to show
    # in addition, if a block is given...
    # yield each result with its index, test, and any captured output
    def detailed_results(test=nil)
      tests = test.nil? ? self.suite.ordered_tests.reverse : [test]
      result_index = 0
      tests.collect do |test|
        result_index += 1
        test.results.reverse.
        select { |result| self.show_result_details?(result) }.
        each {|r| yield r, result_index, test, test.output if block_given?}
      end.compact.flatten
    end

    # get all the results for a klass or other
    def all_results_for(what=nil)
      tests = if what.kind_of?(Class) && what.ancestors.include?(Assert::Context)
        # test results for the given context
        self.suite.ordered_tests.select do |test|
          test.context_info.klass == what
        end
      elsif what.kind_of?(String)
        # test results for the given test file
        self.suite.ordered_tests.select do |test|
          test.context_info.file == what
        end
      else
        selt.suite.ordered_tests
      end

      result_index = 0
      tests.collect do |test|
        result_index += 1
        test.results.
        each {|r| yield r, result_index, test, test.output if block_given?}
      end.compact.flatten
    end

    # only show result details for failed or errored results
    # show result details if a skip or passed result was issues w/ a message
    def show_result_details?(result)
      ([:fail, :error].include?(result.to_sym)) ||
      ([:skip, :ignore].include?(result.to_sym) && result.message)
    end

    def capture_output_start_msg
      "--- stdout ---"
    end
    def capture_output_end_msg
      "--------------"
    end

    # return a list of result symbols that have actually occurred
    def ocurring_result_types
      @result_types ||= [
        :pass, :fail, :ignore, :skip, :error
      ].select { |result_sym| self.count(result_sym) > 0 }
    end

    # print a result summary message for a given result type
    def result_summary_msg(result_type)
      if result_type == :pass && self.all_pass?
        self.all_pass_result_summary_msg
      else
        "#{self.count(result_type)} #{result_type.to_s}"
      end
    end

    # generate an appropriate result summary msg for all tests passing
    def all_pass_result_summary_msg
      if self.count(:results) < 1
        "uhh..."
      elsif self.count(:results) == 1
        "pass"
      else
        "all pass"
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
