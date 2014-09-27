require 'mongoid'
require 'pry'
Mongoid.load!("db/mongoid.yml", :development)

class Board
  include Mongoid::Document
  # belongs_to :parent, class_name: "Board", inverse_of: :children
  # has_many :children, class_name: "Board", inverse_of: :parent

  field :contents, type: Array
  field :parent_id, type: String
  field :expanded, type: Boolean, default: false
  field :moves, type: Integer, default: 0
  field :_id, type: String, default: -> { contents.join() }

  def self.build(parent, child)
    Board.create(contents: child, parent_id: parent.contents.join(),
                 moves: parent.moves + 1)
  rescue Moped::Errors::OperationFailure
  end

  def self.next
    b = Board.where(expanded: false).asc(:moves).first
    b.expanded = true
    b.save
    b
  end
end
