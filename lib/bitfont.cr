struct UInt8
  def bits
    Array.new(8) { |i| bit 7 - i }
  end
end

struct Bitfont
  getter glyphs

  def initialize
    @glyphs = {} of Char => Array(Array(UInt8))
  end

  def self.from_bdf(path)
    font, char, rows, width, height = new, ' ', 0, 0, 0

    File.open(path) do |f|
      while line = f.gets
        case line
        when /ENCODING (\d+)/
          char = $1.to_i.chr
        when /BBX (\d+) (\d+)/ # super-basic bounding box handling
          width = $1.to_i if $1.to_i > width
          rows = $2.to_i
          height = rows if rows > height
        when /BITMAP/
          font.glyphs[char] = Array.new(rows) {
            (f.gets || "").hexbytes.flat_map &.bits
          }
        end
      end
    end

    # Make all glyphs have the same width and height for easy rendering.
    font.glyphs.transform_values! { |v|
      [[0u8] * width] * (height - v.size) + v.map(&.first width)
    }
    font
  end

  def render(str, io = STDOUT)
    rows = str.chars.map { |c| @glyphs[c] }.transpose.map &.flatten
    draw rows.reject(&.all? 0), io: io
  end
end
