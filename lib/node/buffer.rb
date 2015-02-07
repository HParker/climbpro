require_relative 'constants'
require_relative 'board'

class Buffer
  def self.get
    Board.new(Constants::CLIMB_10)
  end
end

=begin
require 'redis'
class Database
  def initialize
    @database = Redis.new
  end

  def insert(board)
    @database.sadd("mine", board.rows.to_json)
  end

  def get_one
    @database.spop("mine")
  end
end
=end
