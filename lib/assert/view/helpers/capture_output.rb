module Assert::View::Helpers

  module CaptureOutput

    def show_any_captured_output(output)
      if !output.empty?
        # TODO: move to the base view
        __ view.capture_output_start_msg
        __ output, false
        __ view.capture_output_end_msg
      end
    end

  end

end
