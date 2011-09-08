require 'assert'
require 'assert/suite'

require 'assert/view/base'
require 'stringio'

module Assert::View

  class BaseTest < Assert::Context
    desc "the base view"
    setup do
      @view = Assert::View::Base.new(Assert::Suite.new, StringIO.new("", "w+"))
    end
    subject{ @view }

    should have_accessors :suite, :output_io, :runtime_result_callback
    should have_instance_methods :template_file, :run_tests, :handle_runtime_result
    should have_instance_methods :run_time, :runner_seed, :count, :tests?, :all_passed?
    should have_instance_methods :ocurring_result_types, :result_summary_msg
    should have_instance_methods :all_passed_result_summary_msg, :to_sentence

    # options stuff
    should have_instance_method :options
    should have_class_method :options

    # renderer stuff
    should have_instance_method :render
    should have_class_method :helper

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
