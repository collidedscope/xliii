@[Link(ldflags: "-L #{__DIR__}/../ckociemba/lib -lkociemba")]
lib Kociemba
  PT = "#{__DIR__}/../ckociemba/prunetables"
  fun solution(UInt8*, LibC::Int, LibC::Long, LibC::Int, UInt8*) : UInt8*
end

struct Scramble
  CORNERS = %w[ULB UBR URF UFL DLF DFR DRB DBL]
  EDGES   = %w[UB UR UF UL FL FR BL BR DF DR DB DL]
  CENTERS = %w[U R F D L B]

  # Formatting the pieces as we do above makes it easy to permute and orient
  # them, but the C library expects the cube state as a flat array of faces.
  # This is just here to map the concatenation of our pieces to that format.
  MAP = {
    0, 24, 3, 30, 48, 26, 9, 28, 6,
    7, 27, 5, 35, 49, 39, 17, 43, 19,
    10, 29, 8, 32, 50, 34, 14, 41, 16,
    12, 40, 15, 46, 51, 42, 21, 44, 18,
    1, 31, 11, 37, 52, 33, 23, 47, 13,
    4, 25, 2, 38, 53, 36, 20, 45, 22,
  }

  def self.new(corners_only = false, edges_only = false)
    ptr = nil

    until ptr
      # Generate a cube state by randomly permuting and orienting all pieces.
      facelets = [CORNERS, EDGES, CENTERS].map { |pieces|
        pieces.shuffle.map { |piece|
          piece.chars.rotate rand piece.size
        }
      }.flatten.values_at(*MAP).join

      # If we generated an unsolvable cube, this is NULL and we go again.
      ptr = Kociemba.solution facelets, 24, 10, 0, Kociemba::PT
    end

    # Otherwise, invert the solution to provide a random-state scramble.
    solution = String.new ptr
    LibC.free ptr
    invert solution
  end

  def self.invert(moves)
    inv = {nil => "'", '2' => "2", '\'' => ""}

    moves.split.map { |turn|
      turn[0] + inv[turn[1]?]
    }.reverse.join ' '
  end
end
