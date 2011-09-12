require 'assert/view/base'
require 'assert/view/helpers/ansi'
require 'assert/view/helpers/capture_output'

module Assert::View

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class DefaultView < Base
    helper Helpers::CaptureOutput
    helper Helpers::AnsiStyles

    options do
      styled          true
      passed_styles   :green
      failed_styles   :red, :bold
      errored_styles  :yellow, :bold
      skipped_styles  :cyan
      ignored_styles  :magenta
    end

    template do
      __
      __ view.loaded_tests_statement

      if view.tests?

        __ view.running_tests_statement

        view.run_tests(runner) do |each_result|
          result_sym = each_result.to_sym
          result_abbrev = view.options.send("#{result_sym}_abbrev")
          __ ansi_styled_msg(result_abbrev, result_ansi_styles(result_sym)), false
        end
        __ "\n"  # add a newline after streamed runner output

        view.detailed_results do |result, index, test, output|
          __ ansi_styled_msg(result.to_s, result_ansi_styles(result))
          show_any_captured_output(output)
          __
        end

      end

      # build a summary sentence w/ styled results breakdown
      styled_results_breakdown_statement = view.results_breakdown_statement do |msg, result_type|
        ansi_styled_msg(msg, result_ansi_styles(result_type))
      end

      __ [ view.result_count_statement, ": ", styled_results_breakdown_statement ].join('')
      __
      __ view.run_time_statement
    end

    def loaded_tests_statement
      "Loaded suite (#{view.count(:tests)} test#{'s' if view.count(:tests) != 1})"
    end

    def running_tests_statement
      "Running tests in random order, seeded with: \"#{self.runner_seed}\""
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
