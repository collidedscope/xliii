def pad_with(e, a, n)
  a.concat [e] * (n - a.size)
end

def stretch(a, n)
  n == 1 ? a : a.flat_map { |row| [row.flat_map { |e| [e] * n }] * n }
end

def draw(pixels, size = 1, io = STDOUT)
  # Add dummy row if necessary to ensure we can always process rows pairwise.
  pixels += [[0u8]] if pixels.size.odd?

  stretch(pixels, size).each_slice 2 do |(a, b)|
    m = [a.size, b.size].max
    pad_with 0u8, a, m if a.size < b.size
    pad_with 0u8, b, m if a.size > b.size

    a.zip b do |t, b|
      io << case {t, b}
      when {0, 0}
        ' '
      when {0, 1}
        '▄'
      when {1, 0}
        '▀'
      when {1, 1}
        '█'
      when {0, String}
        "\e[38;#{b}m▄\e[m"
      when {String, 0}
        "\e[38;#{t}m▀\e[m"
      else
        "\e[48;#{t}#{t == b ? "m " : ";38;#{b}m▄"}\e[m"
      end
    end
    io << '\n'
  end
end
