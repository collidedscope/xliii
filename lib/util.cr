module Xliii
  extend self

  def show(str)
    sb = String::Builder.new
    font.render str, io: sb
    differ.render sb.to_s
  end

  def recolor_inspect(color)
    differ.clear
    print "\e[38;#{color}m"
    show "inspect"
    print "\e[m"
  end
end
