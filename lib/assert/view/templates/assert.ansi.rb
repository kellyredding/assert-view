__
__ view.loaded_tests_statement

if view.tests?

  __ view.running_tests_statement

  view.run_tests(runner) do |each_result|
    result_sym = each_result.to_sym
    result_abbrev = view.options.send("#{result_sym}_abbrev")
    __ ansi_styled_msg(result_abbrev, result_ansi_styles(result_sym)), false
  end
  __ "\n"  # add a newline after streamed runner output

  view.detailed_results do |result, output|
    __ ansi_styled_msg(result.to_s, result_ansi_styles(result))

    if !output.empty?
      __ view.result_output_start_msg
      __ output, false
      __ view.result_output_end_msg
    end

    __
  end

end

# build a summary sentence w/ styled results breakdown
styled_results_breakdown_statement = view.results_breakdown_statement do |msg, result_type|
  ansi_styled_msg(msg, result_ansi_styles(result_type))
end

__ [ view.result_count_statement, ": ", styled_results_breakdown_statement ].join('')
__
__ view.run_time_statement
