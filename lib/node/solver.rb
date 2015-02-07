require 'celluloid'
require_relative 'board'

class Solver
  # include Celluloid # TODO: use Celluloid
  SPACE_CHAR = "0"
  IMOVABLES = ["#","0"]

  Piece = Struct.new(:char, :positions)

  def initialize(board)
    @board = board.rows
    @height = board.height
    @width = board.width
  end

  def next_boards
    pieces = whole_pieces(proximal_pieces(find_spaces))
    pieces.map { |piece| try_move(piece) }.flatten.compact
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

  def proximal_pieces(spaces)
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
    Piece.new(char, spots)
  end

  def try_move(piece)
    moves = [
             piece.positions.map { |y, x| [y+1, x] },
             piece.positions.map { |y, x| [y-1, x] },
             piece.positions.map { |y, x| [y, x-1] },
             piece.positions.map { |y, x| [y, x+1] }
                                                 ]

    new_boards = moves.map { |move|
      new_board = copy
      new_board.lift(piece)
      if new_board.valid?(move)
        new_board.place(move, piece.char)
        raise "Found it! #{new_board}" if new_board.is_goal?
        new_board
      else
        nil
      end
    }
  end

  def copy
    # TODO: find a more efficient deep copy to put here.
    # might even just be able to do @board.map()
    Board.new(Marshal.load(Marshal.dump(@board)))
  end
end
