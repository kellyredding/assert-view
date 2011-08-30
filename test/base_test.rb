require 'assert'
require 'assert/suite'

require 'assert/view/base'
require 'stringio'

module Assert::View

  class BaseTest < Assert::Context
    desc "the view base"
    setup do
      @view = Assert::View::Base.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_reader :suite
    should have_instance_methods :render, :handle_runtime_result, :options
    should have_class_method :options

  end

  class BaseOptionsTest < Assert::Context
    desc "options for the base view"
    subject do
      Assert::View::Base.options
    end

    should "be an Options::Base object" do
      assert_kind_of Assert::Options::Base, subject
    end

    should "default its result abbreviations" do
      assert_equal '.', subject.default_passed_abbrev
      assert_equal 'F', subject.default_failed_abbrev
      assert_equal 'I', subject.default_ignored_abbrev
      assert_equal 'S', subject.default_skipped_abbrev
      assert_equal 'E', subject.default_errored_abbrev
    end

  end



end
