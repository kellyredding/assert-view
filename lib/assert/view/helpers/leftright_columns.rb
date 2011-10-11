module Assert::View::Helpers

  module LeftrightColumns

    def left_column(text, opts={})
      col_width = opts[:width] || self.view.left_column_width
      __ case view.options.left_column_justify
      when :left
        text.to_s+" "*(col_width-(text.to_s.size))
      else
        " "*(col_width-(text.to_s.size))+text.to_s+" "
      end, false
    end

    def right_column(text, opts={})
      lines = text.split("\n")
      right_columnize(lines.first, opts)
      lines[1..-1].each do |line|
        self.left_column("")
        right_columnize(line, opts)
      end
      __ if opts[:endline]
    end

    def right_columnize(text, opts={})
      col_width = opts[:width] || self.view.right_column_width
      # split text into array of limit sizes

      n,r = text.size.divmod(col_width)
      grps = (0..(n-1)).collect do |i|
        i == 0 ? text[i*col_width,col_width] : " "+text[i*col_width,col_width]
      end
      if r > 0
        grps << (n > 0 ? " "+text[-r,r] : text[-r,r])
      end

      __ grps.first
      if grps.size > 1
        grps[1..-1].each do |g|
          self.left_column("")
          __ g
        end
      end
    end

  end

end
