require 'assert/result'
require 'assert/options'
require 'assert/view/base'

module Assert::View

  class Terminal < Base

    def loaded_tests_statement
      "Loaded suite (#{view.count(:tests)} test#{'s' if view.count(:tests) != 1})"
    end

    def running_tests_statement
      "Running tests in random order, seeded with: \"#{self.runner_seed}\""
    end

    # show test details in reverse order from how they were collected (FILO)
    def detailed_tests
      @detailed_tests ||= self.suite.ordered_tests.reverse
    end

    # get all the results that have details to show
    # in addition, if a block is given...
    # yield each result with its test output
    def detailed_results(test=nil)
      tests = test.nil? ? self.detailed_tests : [test]
      tests.collect do |test|
        test.results.
        select { |result| self.show_result_details?(result) }.
        each {|r| yield r, test.output if block_given?}
      end.compact.flatten
    end

    # only show result details for failed or errored results
    # show result details if a skip or passed result was issues w/ a message
    def show_result_details?(result)
      ([:failed, :errored].include?(result.to_sym)) ||
      ([:skipped, :ignored].include?(result.to_sym) && result.message)
    end

    def result_output_start_msg
      "--- stdout ---"
    end
    def result_output_end_msg
      "--------------"
    end

    # generate a sentence fragment describing the breakdown of test results
    # if a block is given, yield each msg in the breakdown for custom template formatting
    def results_breakdown_statement
      self.to_sentence(self.ocurring_result_types.collect do |result_type|
        yield(self.result_summary_msg(result_type), result_type) if block_given?
      end)
    end

    def result_count_statement
      "#{self.count(:results)} test result#{'s' if self.count(:results) != 1}"
    end

    def run_time_statement
      "(#{self.run_time} seconds)"
    end

  end

end
