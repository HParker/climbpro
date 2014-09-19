require 'colorize'

# TODO: Fix place, fix whole piece, fix repeats
class Solver

  attr_accessor :board

  SPACE_CHAR = "0"
  IMOVABLES = ["#","0"]

  def initialize(board, mode: :sprint, colors: nil)
    @board = board
    @height = board.size
    @width = board[0].size
    @mode = mode
    @colors = colors
  end

  def pretty_print
    puts "- - - - - - - - - - -"
    @board.each do |row|
      if @colors
        colored_row = row.map do |spot|
          color = @colors[spot]
          "#{spot}".colorize(background: color)
        end
        puts
        puts colored_row.join("   ")
      else
        p row.join("  ")
      end
    end
    puts "- - - - - - - - - - -\n\n"
  end

  def next_boards
    pieces = whole_pieces(pieces_that_might_move(find_spaces))
    pieces.map { |piece| try_move(piece) }.flatten.compact
  end

  def place(positions, char:)
    positions.each do |y, x|
      @board[y][x] = char
    end
  end

  def valid?(new_positions)
    collisions = new_positions.select { |y, x|
      return false if y > @height-1 || x > @width-1
      @board[y][x] != "0"
    }
    collisions.empty?
  end

  def lift(piece)
    piece[1].each { |y, x|
      if @board[y][x] == piece[0]
        @board[y][x] = "0"
      else
        puts "lifting piece improperly!"
        binding.pry
      end
    }
  end

  private

  def find_spaces
    spaces = []
    @board.each_index do |row_i|
      @board[row_i].each_index do |char_i|
        spaces << [row_i, char_i] if @board[row_i][char_i] == SPACE_CHAR
        return spaces if spaces.size == 4
      end
    end
    raise "seems a space was lost along the way. :("
  end

  def pieces_that_might_move(spaces)
    pieces = {}
    spaces.each do |(y, x)|
      [[y+1, x],
       [y-1, x],
       [y, x+1],
       [y, x-1]].each do |y1, x1|
        pieces[@board[y1][x1]] = [y1, x1] if y1.between?(0, @height-1) && x1.between?(0, @width-1) && !IMOVABLES.include?(@board[y1][x1])
      end
    end
    pieces
  end

  def whole_pieces(proximal_spots)
    proximal_spots.map { |spots| whole_piece(spots) }
  end

  def whole_piece(spot, spots = [])
    char, (y, x) = spot
    if y < @height && x < @width && @board[y][x] == char # && spots.size < 5
      spots << [y, x]
      whole_piece([char, [y+1,x]], spots) unless spots.include?([y+1, x])
      whole_piece([char, [y-1,x]], spots) unless spots.include?([y-1, x])
      whole_piece([char, [y,x+1]], spots) unless spots.include?([y, x+1])
      whole_piece([char, [y,x-1]], spots) unless spots.include?([y, x-1])
    end
    [char, spots]
  end

  def try_move(piece)
    moves = [
             piece[1].map { |y, x| [y+1, x] },
             piece[1].map { |y, x| [y-1, x] },
             piece[1].map { |y, x| [y, x-1] },
             piece[1].map { |y, x| [y, x+1] }
                                                 ]

    moves.map { |move|
      new_board = copy
      new_board.lift(piece)
      if new_board.valid?(move)
        new_board.place(move, char: piece[0])
        new_board
      else
        nil
      end
    }
  end

  def copy
    # TODO: find a more efficient deep copy to put here.
    # might even just be able to do @board.map()
    Solver.new(Marshal.load(Marshal.dump(@board)))
  end
end
