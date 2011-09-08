require 'assert'

require 'assert/view/terminal'
require 'stringio'

module Assert::View

  class TerminalTest < Assert::Context
    desc "the terminal view"
    setup do
      @view = Assert::View::Terminal.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_instance_methods :loaded_tests_statement, :running_tests_statement
    should have_instance_methods :detailed_tests, :detailed_results, :show_result_details?
    should have_instance_methods :result_output_start_msg, :result_output_end_msg
    should have_instance_methods :results_breakdown_statement, :result_count_statement
    should have_instance_methods :run_time_statement

  end
end
