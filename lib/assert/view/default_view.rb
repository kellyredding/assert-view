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
      styled         true
      pass_styles    :green
      fail_styles    :red, :bold
      error_styles   :yellow, :bold
      skip_styles    :cyan
      ignore_styles  :magenta
    end

    template do
      __ view.loaded_tests_statement

      if view.tests?

        __ view.running_tests_statement

        view.run_tests(runner) do |result|
          result_abbrev = view.options.send("#{result.to_sym}_abbrev")
          __ ansi_styled_msg(result_abbrev, result_ansi_styles(result)), false
        end
        __ "\n"  # add a newline after streamed runner output

        view.detailed_results do |result, index, test, output|
          __ ansi_styled_msg(result.to_s, result_ansi_styles(result))
          __ captured_output(output) if output && !output.empty?
          __
        end

      end

      __ [  view.result_count_statement, ": ",
            (view.results_breakdown_statement do |msg, result_sym|
              ansi_styled_msg(msg, result_ansi_styles(result_sym))
            end)
         ].join('')
      __
      __ view.run_time_statement
    end

    def loaded_tests_statement
      "Loaded suite (#{self.test_count_statement})"
    end

    def test_count_statement
      "#{self.count(:tests)} test#{'s' if self.count(:tests) != 1}"
    end

    def running_tests_statement
      "Running tests in random order, seeded with \"#{self.runner_seed}\""
    end

    # generate a sentence fragment describing the breakdown of test results
    # if a block is given, yield each msg in the breakdown for custom template formatting
    def results_breakdown_statement
      self.to_sentence(self.ocurring_result_types.collect do |result_sym|
        yield(self.result_summary_msg(result_sym), result_sym) if block_given?
      end)
    end

    def result_count_statement
      "#{self.count(:results)} result#{'s' if self.count(:results) != 1}"
    end

    def run_time_statement
      "(#{self.run_time} seconds)"
    end

  end

end
