module Assert::View::Helpers
  module TestUnit

    def show_testunit_detailed_result(result, index, test)
      # TODO: put result name in assert result model
      __ "  #{index}) #{result.respond_to?(:name) ? result.name : ""}:"
      __ "#{result.test_name}(#{test.context_class.name}):"
      __ result.message
      __ "    #{result.backtrace.filtered.first.to_s}"
    end

  end
end

