require 'mongoid'
require 'pry'
Mongoid.load!("db/mongoid.yml", :development)

class Board
  include Mongoid::Document

  field :board, type: Array
  field :parent_id, type: String
  field :expanded, type: Boolean, default: false
  field :moves, type: Integer, default: 0
  field :_id, type: String, default: -> { board.join }
  field :direction, type: Symbol

  def self.build(parent, child)
    Board.create(board: child.board,
                 parent_id: parent.board.join,
                 direction: child.direction,
                 moves: parent.moves + 1)
  rescue Moped::Errors::OperationFailure
    puts "Duplicate Board"
  end

  def self.next
    b = Board.where(expanded: false).asc(:moves).first
    b.expanded = true
    b.save
    b
  end
end
