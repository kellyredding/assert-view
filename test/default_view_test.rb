require 'assert'

require 'assert/view/default_view'
require 'stringio'

module Assert::View

  class DefaultViewTest < Assert::Context
    desc "the default view"
    setup do
      @view = Assert::View::DefaultView.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_instance_methods :loaded_tests_statement, :running_tests_statement
    should have_instance_methods :results_breakdown_statement, :result_count_statement
    should have_instance_methods :run_time_statement

  end
end
