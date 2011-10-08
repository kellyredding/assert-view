module Assert::View::Helpers

  module CaptureOutput

    def captured_output(output)
      if !output.empty?
        # TODO: move to the base view
        [ view.capture_output_start_msg,
          output + view.capture_output_end_msg
        ].join("\n")
      end
    end

  end

end
