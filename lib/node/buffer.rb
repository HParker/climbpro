# require 'redis'
require 'json'
require 'celluloid/autostart'
require_relative 'constants'
require_relative 'board'
require 'dcell'
require 'celluloid/redis'

DCell.start

class Buffer
  include Celluloid

  def initialize
    @redis = ::Redis.new(:driver => :celluloid)
    @database_node = DCell::Node["database"]
    @database = @database_node[:database]
  end

  def insert(board)
    @redis.sadd("climbpro", board.to_json)
  end

  def keep_full
    loop do
      if @redis.scard("climbpro").to_i < 100
        insert(@database.get)
      end
    end
  end

  def get
    # insert(@database.get)
    until @redis.scard("climbpro").to_i >= 1; puts @redis.scard("climbpro"); sleep 0.5; end
    Board.new(JSON.parse(@redis.spop("climbpro")))
  end

  def buffer_out(boards)
    boards.each do |board|

    end
  end

  private

  def near_empty
    true
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
