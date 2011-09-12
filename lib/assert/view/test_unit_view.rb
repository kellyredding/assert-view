require 'assert/view/base'
require 'assert/view/helpers/capture_output'
require 'assert/view/helpers/test_unit'

module Assert::View

  # this view renders in test/unit style

  class TestUnitView < Base
    helper Helpers::CaptureOutput
    helper Helpers::TestUnit

    template do
      __ view.loaded_suite_statement
      __ view.started_statement

      if view.tests?

        view.run_tests(runner) do |each_result|
          __ view.options.send("#{each_result.to_sym}_abbrev"), false
        end
        __
        __ view.finished_statement
        __

        view.detailed_results do |result, index, test, output|
          show_testunit_detailed_result(result, index, test)
          show_any_captured_output(output)
          __
        end

      end

      __ view.results_breakdown_statement
    end

    def loaded_suite_statement
      "Loaded suite #{$0.to_s}"
    end

    def started_statement
      "Started"
    end

    def finished_statement
      "Finished in #{self.run_time} seconds."
    end

    # generate a sentence fragment describing the breakdown of test results
    # if a block is given, yield each msg in the breakdown for custom template formatting
    def results_breakdown_statement
      [ "#{self.count(:tests)} tests, #{self.count(:results)} assertions",
        self.to_sentence(self.ocurring_result_types.collect do |result_type|
          self.result_summary_msg(result_type)
        end)
      ].join(", ")
    end

  end

end

