require 'assert/view/test_unit_view'
require 'assert/view/helpers/ansi'

module Assert::View

  # this view add simple color ansi output to the TestUnitView

  class RedgreenView < TestUnitView
    helper Helpers::CaptureOutput
    helper Helpers::AnsiStyles

    options do
      styled          true
      passed_styles   :green
      failed_styles   :red
      errored_styles  :yellow
      skipped_styles  :yellow
      ignored_styles  :yellow
    end

    # this template is identical to the TestUnitView template, except:
    # - the run_tests result handler block shows ansi styled output
    # - each detailed result renders its name styled
    # - the results_breakdown_statement renders ansi styled
    template do
      __ view.loaded_suite_statement
      __ view.started_statement

      if view.tests?

        view.run_tests(runner) do |each_result|
          # the run_tests result handler from DefaultView
          result_sym = each_result.to_sym
          result_abbrev = view.options.send("#{result_sym}_abbrev")
          __ ansi_styled_msg(result_abbrev, result_ansi_styles(result_sym)), false
        end
        __
        __ view.finished_statement
        __

        # same as the test/unit template except styling result name
        view.detailed_results do |result, index, test, output|
          # TODO: remove and call directly once result name is in assert
          result_name = result.respond_to?(:name) ? result.name : ""
          __ "  #{index}) #{ansi_styled_msg(result_name, result_ansi_styles(result.to_sym))}:"
          __ "#{result.test_name}(#{test.context_class.name}):"
          __ result.message
          __ "    #{result.backtrace.filtered.first.to_s}"

          __ captured_output(output) if output && !output.empty?
          __
        end

      end

      # smae as test/unit, except styled
      __ ansi_styled_msg(view.results_breakdown_statement, view.all_pass? ? :green : :red)
    end

  end

end

