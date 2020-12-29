class Cube
  # Moves are defined as transpositions of this Speffz represenation of a
  # solved cube. It's kinda lazy and doesn't get a chance to cooperate with
  # the scramble generator, but it's still pretty elegant.
  SOLVED = "AaBbCcDd1EeFfGgHh2IiJjKkLl3MmNnOoPp4QqRrSsTt5UuVvWwXx6"
  MOVES  = {
    'U' => "DdAaBbCc1IiJfGgHh2MmNjKkLl3QqRnOoPp4EeFrSsTt5UuVvWwXx6",
    'L' => "SaBbCcRr1HhEeFfGg2AiJjKkDd3MmNnOoPp4QqXxUsTt5IuVvWwLl6",
    'F' => "AaBbFfGd1EeUuVgHh2LlIiJjKk3DmNnOoCc4QqRrSsTt5PpMvWwXx6",
    'R' => "AaJjKcDd1EeFfGgHh2IiVvWkLl3PpMmNnOo4CqRrSsBb5UuTtQwXx6",
    'B' => "NnObCcDd1BeFfGgAa2IiJjKkLl3MmWwXoPp4TtQqRrSs5UuVvHhEx6",
    'D' => "AaBbCcDd1EeFfSsTh2IiJjGgHl3MmNnKkLp4QqRrOoPt5XxUuVvWw6",
  }

  getter state = SOLVED

  def initialize(scramble = nil)
    exec scramble if scramble
  end

  def resolve(spec)
    spec.chars.map { |c| @state[SOLVED.index(c) || 0] }.join
  end

  def move(moves)
    moves.each { |m| @state = resolve MOVES[m] }
  end

  def exec(moves)
    move moves
      .tr("'", "3")
      .gsub(/(\w)(\d)/) { $1 * $2.to_i }
      .delete(' ').chars
  end

  def render(size, io = STDOUT)
    paint = Xliii.paint
    net = ["AaB", "d1b", "DcC",
           "EeFIiJMmNQqR", "h2fl3jp4nt5r", "HgGLkKPoOTsS",
           "UuV", "x6v", "XwW"]

    draw net.map_with_index { |f, i|
      [0u8] * ((3..5) === i ? 0 : 3) + resolve(f).chars.map { |c|
        paint[(SOLVED.index(c) || 0) // 9]
      }
    }, size, io
  end
end
