require 'assert'

require 'assert/view/leftright_view'
require 'stringio'

module Assert::View

  class LeftrightViewTest < Assert::Context
    desc "the leftright view"
    setup do
      @view = Assert::View::LeftrightView.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_instance_methods :loaded_suite_statement, :started_statement
    should have_instance_methods :leftright_groups, :left_column_display, :left_column_width

  end
end
