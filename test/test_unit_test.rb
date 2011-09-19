require 'assert'

require 'assert/view/test_unit_view'
require 'stringio'

module Assert::View

  class TestUnitViewTest < Assert::Context
    desc "the test/unit view"
    setup do
      @view = Assert::View::TestUnitView.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_instance_methods :loaded_suite_statement, :started_statement
    should have_instance_methods :finished_statement, :results_breakdown_statement

  end
end
