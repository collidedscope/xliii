module Xliii
  extend self

  def play_audio(file)
    `ffplay -nodisp -autoexit #{__DIR__}/../audio/#{file} 2> /dev/null`
  end

  def prelude
    puts scramble = Xliii.scramble, ""
    Cube.new(scramble).render config("scramble.size").as_i

    puts "Hit any key to start inspection, then another to start timer.\n\n"
    STDIN.raw &.read_char
    differ.set_origin
    print "\e7" # save cursor

    show "inspect"
    queue_scramble # opportune moment to prevent any visual delays
  end

  def inspection
    elapsed, solving = 0, nil
    alerts = config("inspection.alerts")

    if alerts == "female"
      a8, a12 = "f8.mp3", "f12.mp3"
    elsif alerts == "male"
      a8, a12 = "m8.mp3", "m12.mp3"
    end

    spawn do
      loop do
        break if solving
        sleep 1
        elapsed += 1

        if !solving && a8
          play_audio a8 if elapsed == 8
          play_audio a12 if elapsed == 12
        end
      end
    end

    solving = if config("inspection.release").as_bool
                keyup.as Time
              else
                STDIN.raw &.read_char
                Time.local
              end
  end

  def timed_solve
    prelude
    start = inspection
    time_it start
  end

  def time_it(start)
    complete = nil
    differ.clear

    if config("timer.display") == "none"
      show "solve"
    else
      prec = config("timer.precision").as_i
      fmt = "%.#{prec if prec > 0}f"

      spawn do
        loop do
          break if complete
          t = Time.local - start
          ts = fmt % (t.seconds + t.nanoseconds / 1e9)
          if config("timer.display") == "bitmap"
            show ts
          else
            print "\r#{ts}"
          end

          sleep 0.01
        end
      end
    end

    [STDIN.raw &.read_char, complete = Time.local - start]
  end
end
