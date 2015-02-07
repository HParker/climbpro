require 'json'

class Board
  attr_reader :height, :width, :rows

  def initialize(rows)
    @rows = rows
    @height = rows.size
    @width = rows[0].size
  end

  def self.from_json(board_json)
    Board.new(JSON.parse(board_json))
  end

  def lift(piece)
    piece.positions.each { |y, x|
      if @rows[y][x] == piece.char
        @rows[y][x] = "0"
      else
        raise "lifted piece improperly! baord: #{@rows}, piece: #{piece}"
      end
    }
  end

  def place(positions, char)
    positions.each do |y, x|
      @rows[y][x] = char
    end
  end

  def valid?(new_positions)
    collisions = new_positions.select { |y, x|
      return false if y > @height-1 || x > @width-1
      @rows[y][x] != "0"
    }
    collisions.empty?
  end

  def is_goal?
    @rows[1] == %w(# # U U # #) # TODO: make generic
  end
end
