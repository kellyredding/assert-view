require 'assert/view/base'
require 'assert/view/helpers/capture_output'

module Assert::View

  # this view renders in test/unit style

  class TestUnitView < Base
    helper Helpers::CaptureOutput

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
          # TODO: remove and call directly once result name is in assert
          result_name = result.respond_to?(:name) ? result.name : ""
          __ "  #{index}) #{result_name}:"
          __ "#{result.test_name}(#{test.context_class.name}):"
          __ result.message
          __ "    #{result.backtrace.filtered.first.to_s}"

          __ captured_output(output)
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

