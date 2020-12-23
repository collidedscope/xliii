# One-time initialization of various structures. Crystal doesn't yet support
# instance variables on Modules, and @@ all over the code is ugly, so we roll
# our own caching getters. There's probably a better way, but it works.

module Xliii
  extend self

  def config(key = nil)
    @@config ||= YAML.parse File.read "#{__DIR__}/../config.yml"
    return YAML::Any.new nil unless c = @@config

    # Provide ourselves with a nicer syntax for getting configuration
    # values: config("foo.bar") as opposed to config["foo"]["bar"].
    case (keys = key.split '.').size
    when 2
      c.dig keys[0], keys[1]
    when 3
      c.dig keys[0], keys[1], keys[2]
    else
      c[key]
    end
  end

  def differ
    @@differ ||= Differ.new
  end

  @@font : Bitfont?
  def font
    @@font ||= Bitfont.from_bdf "#{__DIR__}/../fonts/#{config "font.name"}.bdf"
    # @@font ||= Bitfont.from_bdf Dir["fonts/*"].sample
  end

  @@scrambles = [Scramble.new.as String]

  def scramble
    @@scrambles.shift
  end

  # Scramble generation can be "slow", so we call this after displaying the
  # current scramble to ensure the user never has to "wait" for a new one.
  def queue_scramble
    @@scrambles << Scramble.new
  end

  @@paint : Array(String)?
  def paint
    @@paint ||= config("scramble.colors").as_h.values.map { |v|
      case v.raw
      when String
        "2;" + v.as_s.delete('#').hexbytes.join(';')
      else
        "5;#{v}"
      end
    }
    # [231, 202, 34, 196, 21, 226]
  end
end
