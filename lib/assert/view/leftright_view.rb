require 'assert/view/default_view'
require 'assert/view/helpers/leftright_columns'

module Assert::View

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class LeftrightView < DefaultView
    helper Helpers::LeftrightColumns

    options do
      default_right_column_width  80
    end

    template do
      __ view.loaded_suite_statement
      __ view.started_statement

      if view.tests?
        __

        view.run_tests(runner)

        view.leftright_groups.each do |grouping|
          result_abbrevs = ""
          view.all_results_for(grouping) do |result, index, test, output|
            result_abbrev = view.options.send("#{result.to_sym}_abbrev")
            result_abbrevs << ansi_styled_msg(result_abbrev, result_ansi_styles(result))
          end
          left_column(view.left_column_display(grouping))
          right_column(result_abbrevs, {
            :width => (view.options.styled ? 10 : 1)*view.right_column_width
          })

          result_details = []
          view.all_results_for(grouping) do |result, index, test, output|
            if view.show_result_details?(result)
              result_details << [
                ansi_styled_msg(result.to_s, result_ansi_styles(result)),
                captured_output(output),
                "\n"
              ].compact.join("\n")
            end
          end
          if result_details.size > 0
            left_column("")
            right_column(result_details.join, {:endline => true})
          end
        end

      end

      __
      __ [  view.result_count_statement, ": ",
            (view.results_breakdown_statement do |msg, result_sym|
              ansi_styled_msg(msg, result_ansi_styles(result_sym))
            end)
         ].join('')
      __
      __ view.run_time_statement
    end

    def loaded_suite_statement
      "Loaded suite #{$0.to_s}"
    end

    def started_statement
      "Started"
    end

    def leftright_groups
      self.ordered_suite_contexts
    end

    def left_column_display(klass)
      klass.to_s
    end

    def left_column_width
      @left_col_width ||= self.suite_contexts.inject(0) do |max_size, klass|
        klass.to_s.size > max_size ? klass.to_s.size : max_size
      end + 1
    end

    def right_column_width
      self.options.right_column_width
    end

  end

end
