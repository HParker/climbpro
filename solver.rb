# TODO: Fix place, fix whole piece, fix repeats
class Solver

  SPACE_CHAR = "0"
  IMOVABLES = ["I","0"]

  def initialize(board)
    @board = board
  end


  def pp
    puts "- - - - - - - - - - -"
    @board.each do |row|
      p row.join("  ")
    end
    puts "- - - - - - - - - - -"
    puts
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
      @board[y][x] != "0"
    }
    collisions.empty?
  end

  def lift(piece)
    piece.each { |y, x| @board[y][x] = "0" }
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

  # TODO: deal with boundaries.
  def pieces_that_might_move(spaces)
    pieces = {}
    spaces.each do |(y, x)|
      [[y+1, x],
       [y-1, x],
       [y, x+1],
       [y, x-1]].each do |y1, x1|
        pieces[@board[y1][x1]] = [y1, x1] if !IMOVABLES.include?(@board[y1][x1]) && y1 > -1 && x1 > -1
      end
    end
    pieces
  end

  def whole_pieces(proximal_spots)
    proximal_spots.map { |spots| whole_piece(spots) }
  end

  # TODO: optimize me!
  # probably want to do a recursive expansion
  # this just relies on the fact that any part of a piece
  # is more than 3 places away from any other part.
  # spots checked:
  #     X
  #   X X X
  # X X O X X
  #   X X X
  #     X

  def whole_piece(spot, spots = [])
    char, (y, x) = spot
    if @board[y][x] == char # && spots.size < 5
      spots << [y, x]
      whole_piece([char, [y+1,x]], spots) unless spots.include?([y+1, x])
      whole_piece([char, [y-1,x]], spots) unless spots.include?([y-1, x])
      whole_piece([char, [y,x+1]], spots) unless spots.include?([y, x+1])
      whole_piece([char, [y,x-1]], spots) unless spots.include?([y, x-1])
    else
      [char, spots]
    end
  end

  def try_move(piece)
    moves = [
             piece[1].map { |y, x| [y+1, x] },
             piece[1].map { |y, x| [y-1, x] },
             piece[1].map { |y, x| [y, x-1] },
             piece[1].map { |y, x| [y, x+1] }]

    moves.map { |move|
      new_board = copy
      new_board.lift(piece[1])
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
