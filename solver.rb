require 'colorize'
require 'pry'

class Solver

  Piece = Struct.new(:identity, :positions)
  Board = Struct.new(:board, :direction)

  attr_accessor :board, :direction

  SPACE = "0".ord
  IMOVABLES = ["#".ord,"0".ord]

  def initialize(parent, colors: nil)
    @board = parent.board
    @parent_direction = parent.direction
    @height = parent.board.size
    @width = parent.board[0].size
    @colors = colors
  end

  def pretty_print
    puts "- - - - - - - - - - -"
    @board.each do |row|
      if @colors
        colored_row = row.map do |char_code|
          spot = char_code.chr
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

  def place(piece, identity:)
    piece.each do |y, x|
      @board[y][x] = identity
    end
    @direction = direction
  end

  def valid?(new_positions)
    collisions = new_positions.select { |y, x|
      return false if y > @height-1 || x > @width-1 # TODO: might not be needed with explicit boundries
      @board[y][x] != SPACE
    }
    collisions.empty?
  end

  def lift(piece)
    piece.positions.each { |y, x|
      if @board[y][x] == piece.identity
        @board[y][x] = SPACE
      else
        raise "lifting piece improperly! #{piece.inspect} #{board.inspect}"
      end
    }
  end

  private

  def find_spaces
    spaces = []
    @board.each_index do |row_i|
      @board[row_i].each_index do |char_i|
        spaces << [row_i, char_i] if @board[row_i][char_i] == SPACE
        return spaces if spaces.size == 4
      end
    end
    raise "seems a space was lost. #{spaces.inspect} \n #{@board.inspect}"
  end

  def pieces_that_might_move(spaces)
    pieces = {}
    spaces.each do |(y, x)|
      around(y, x).each do |y1, x1|
        # TODO: likely don't need .between? check now that we have explicit boundaries.
        # need to write tests first to feel comfortable changing this
        pieces[@board[y1][x1]] = [y1, x1] if y1.between?(0, @height-1) && x1.between?(0, @width-1) && !IMOVABLES.include?(@board[y1][x1])
      end
    end
    pieces
  end

  def around(y, x)
    [[y + 1, x],
     [y - 1, x],
     [y, x + 1],
     [y, x - 1]]
  end

  def whole_pieces(proximal_spots)
    proximal_spots.map { |spots| whole_piece(spots) }
  end

  def whole_piece(spot, spots = [])
    identity, (y, x) = spot
    if y < @height && x < @width && @board[y][x] == identity
      spots << [y, x]
      around(y, x).each do |y1, x1|
        whole_piece([identity, [y1,x1]], spots) unless spots.include?([y1, x1])
      end
    end
    Piece.new(identity, spots)
  end

  def try_move(piece)
    case @parent_direction
    when :N
      moves = [
               [piece.positions.map { |y, x| [y-1, x] }, :N],
               [piece.positions.map { |y, x| [y, x-1] }, :W],
               [piece.positions.map { |y, x| [y, x+1] }, :E]
              ]
    when :S
      moves = [
               [piece.positions.map { |y, x| [y+1, x] }, :S],
               [piece.positions.map { |y, x| [y, x-1] }, :W],
               [piece.positions.map { |y, x| [y, x+1] }, :E]
              ]
    when :E
      moves = [
               [piece.positions.map { |y, x| [y+1, x] }, :S],
               [piece.positions.map { |y, x| [y-1, x] }, :N],
               [piece.positions.map { |y, x| [y, x+1] }, :E]
              ]
    when :W
      moves = [
               [piece.positions.map { |y, x| [y+1, x] }, :S],
               [piece.positions.map { |y, x| [y-1, x] }, :N],
               [piece.positions.map { |y, x| [y, x-1] }, :W]
              ]
    else
      moves = [
               [piece.positions.map { |y, x| [y+1, x] }, :S],
               [piece.positions.map { |y, x| [y-1, x] }, :N],
               [piece.positions.map { |y, x| [y, x-1] }, :W],
               [piece.positions.map { |y, x| [y, x+1] }, :E]
              ]
    end
    moves.map { |moved_piece, direction|
      new_board = copy(direction: direction)
      new_board.lift(piece)
      if new_board.valid?(moved_piece)
        new_board.place(moved_piece, identity: piece.identity)
        new_board
      else
        nil
      end
    }
  end

  def copy(direction:)
    # TODO: find a more efficient deep copy to put here.
    # might even just be able to do @board.map()
    Solver.new(Board.new(Marshal.load(Marshal.dump(@board)), direction))
  end
end
