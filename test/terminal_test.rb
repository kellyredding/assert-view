require 'assert'

require 'assert/core/options'
require 'assert/view/terminal'

module Assert::View

  class TerminalTest < Assert::Context
    desc "options for the terminal view"
    subject do
      Assert::View::Terminal.options
    end

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, Assert::View::Terminal.options
    end

    should "default the styled option" do
      assert_equal false, subject.default_styled
    end

    should "default its result abbreviations" do
      assert_equal '.', subject.default_passed_abbrev
      assert_equal 'F', subject.default_failed_abbrev
      assert_equal 'I', subject.default_ignored_abbrev
      assert_equal 'S', subject.default_skipped_abbrev
      assert_equal 'E', subject.default_errored_abbrev
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
