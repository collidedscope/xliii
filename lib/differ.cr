class Differ
  def initialize
    @x, @y, @prev = 1, 1, ""
  end

  def render(str, io = STDOUT)
    return io << (@prev = str) if @prev.empty?
    changes = [] of {Int32, Int32, Char}

    # Hack to grow incoming string as necessary to ensure its lines can be
    # zipped with the previous ones. As a consequence, our underlying buffer
    # can only ever grow; that's fine because this is a cursor-based printer.
    str += "\n" * (@prev.lines.size - str.lines.size + 1)

    @prev.lines.zip(str.lines).each_with_index do |(p, s), i|
      s.each_char.with_index do |c, j|
        changes << {i + @y, j + @x, c} if c != p[j]?
      end
    end

    changes.each { |y, x, c| io << "\e[#{y};#{x}H#{c}" }
    @prev = str
  end

  def clear(io = STDOUT)
    render @prev.gsub(/./, ' '), io
  end

  def set_origin
    print "\e[6n" # query cursor position

    if yx = STDIN.raw &.gets 'R'
      yx = yx[2..-2]
      return unless yx[0].number?
      @y, @x = yx.split(';').map &.to_i
    end
  end
end
