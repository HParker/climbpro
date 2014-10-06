require 'mongo'
require 'pry'
class Database

  attr_reader :coll

  def initialize
    client = Mongo::Connection.new # defaults to localhost:27017
    db     = client['climb-pro-db']
    @coll  = db['example-collection']
  end

  def destroy_all
    @coll.remove
  end

  def next
    board = @coll.find(expanded: false).sort(:moves).first
    board["expanded"] = true
    @coll.update({"_id" => board["_id"]}, board)
    Board.new(board: board["board"], moves: board["moves"], parent_id: board["parent_id"])
  end

  def builder(children)
    children.each do |child|
      build(child)
    end
  end

  def build(child)
    @coll.insert({
                   _id: child.board.join,
                   board: child.board,
                   expanded: child.expanded,
                   parent_id: child.parent_id,
                   moves: child.moves
                 })
  rescue Mongo::OperationFailure
  end

  def on_level?(n)
    @coll.find(moves: n).count > 1
  end
end

class Board
  attr_reader :board, :moves, :parent_id, :expanded
  def initialize(board:, moves: 0, parent_id: nil, expanded: false)
    @board = board
    @moves = moves
    @parent_id = parent_id
    @expanded = expanded
  end
end
