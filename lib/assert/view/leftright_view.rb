require 'assert/view/default_view'
require 'assert/view/helpers/leftright_columns'

module Assert::View

  # This is the default view used by assert.  It renders ansi test output
  # designed for terminal viewing.

  class LeftrightView < DefaultView
    helper Helpers::LeftrightColumns

    options do
      default_right_column_width    80
      default_left_column_groupby   :context
      default_left_column_justify   :right
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
      case self.options.left_column_groupby
      when :context
        self.ordered_suite_contexts
      when :file
        self.ordered_suite_files
      else
        []
      end
    end

    def left_column_display(leftcol_value)
      case self.options.left_column_groupby
      when :context
        leftcol_value.to_s.gsub(/Test$/, '')
      when :file
        leftcol_value.to_s.gsub(File.expand_path(".", Dir.pwd), '').gsub(/^\/+test\//, '')
      else
        leftcol_value.to_s
      end
    end

    def left_column_width
      @left_col_width ||= case self.options.left_column_groupby
      when :context
        self.suite_contexts.collect{|f| f.to_s.gsub(/Test$/, '')}
      when :file
        self.suite_files.collect{|f| f.to_s.gsub(File.expand_path(".", Dir.pwd), '').gsub(/^\/+test\//, '')}
      else
        []
      end.inject(0) do |max_size, klass|
        klass.to_s.size > max_size ? klass.to_s.size : max_size
      end + 1
    end

    def right_column_width
      self.options.right_column_width
    end

  end

end
