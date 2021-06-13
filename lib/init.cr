module Xliii
  extend self

  class_getter(config) { YAML.parse File.read "#{__DIR__}/../config.yml" }
  class_getter(differ) { Differ.new }

  class_getter font : Bitfont? do
    Bitfont.from_bdf "#{__DIR__}/../fonts/#{config "font.name"}.bdf"
  end

  class_getter paint : Array(String)? do
    config("scramble.colors").as_h.values.map { |v|
      case v.raw
      when String
        "2;" + v.as_s.delete('#').hexbytes.join(';')
      else
        "5;#{v}"
      end
    }
  end

  def config(key = nil)
    # Provide ourselves with a nicer syntax for getting configuration
    # values: config("foo.bar") as opposed to config["foo"]["bar"].
    case (keys = key.split '.').size
    when 2
      config.dig keys[0], keys[1]
    when 3
      config.dig keys[0], keys[1], keys[2]
    else
      config[key]
    end
  end

  class_getter prev_scramble = Scramble.new.as String
  class_getter scrambles = [prev_scramble] of String

  def scramble
    prev_scramble = scrambles.shift
  end

  # Scramble generation can be "slow", so we call this after displaying the
  # current scramble to ensure the user never has to "wait" for a new one.
  def queue_scramble
    scrambles << Scramble.new
  end
end
