require "yaml"
require "./lib/*"

module Xliii
  def solve
    print "\e[H\e[2J" # clear terminal
    key, time = timed_solve
    @@last = Time.local
    differ.clear
    print "\e[2K\e8" # clear plaintext time and restore cursor

    s = case key
        when '\u007f', '\e' # backspace or escape
          "aborted"
        else
          prec = config("timer.precision").as_i
          fmt = "%.#{prec if prec > 0}f"
          t = time.as Time::Span
          fmt % (t.seconds + t.nanoseconds / 1e9)
        end
    font.render s
  end

  def times
  end

  def retry
    @@scrambles.unshift @@prev_scramble
    solve
  end

  MENU = {
    #  v intentional space
    "1s " => {->solve, "time a solve"},
    "2t"  => {->times, "view times"},
    "3r"  => {->retry, "retry scramble"},
    "qx"  => {->quit, "quit/exit"},
  }

  def show_menu
    MENU.each do |keys, (_, desc)|
      puts "[%s]\t%s" % {keys, desc}
    end
  end

  def main
    print "\e[?1049h"   # save terminal contents
    print "\e[H\e[?25l" # move cursor to top and hide it

    loop do
      show_menu

      if opt = STDIN.raw &.read_char
        if item = MENU.find { |keys, _| keys[opt]? }
          item[1][0].call
        end
      end
    end
  end

  def quit
    print "\e[?25h"   # unhide cursor
    print "\e[?1049l" # restore terminal contents
    exit
  end
end

Xliii.main
