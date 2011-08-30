require 'assert'
require 'assert/options'

require 'assert/view/terminal'

module Assert::View

  class TerminalOptionsTest < Assert::Context
    desc "options for the terminal view"
    subject do
      Assert::View::Terminal.options
    end

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, subject
    end

    should "default the styled option" do
      assert_equal false, subject.default_styled
    end

    should "default its result styles" do
      assert_equal :green, subject.default_passed_styles
      assert_equal [:red, :bold], subject.default_failed_styles
      assert_equal :magenta, subject.default_ignored_styles
      assert_equal :cyan, subject.default_skipped_styles
      assert_equal [:yellow, :bold], subject.default_errored_styles
    end

  end

end
