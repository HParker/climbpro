require 'mongoid'

Mongoid.load!("db/mongoid.yml", :development)

class Board
  include Mongoid::Document

  belongs_to :parent, class_name: "Board", inverse_of: :children
  has_many :children, class_name: "Board", inverse_of: :parent
  
  field :board, type: String
  field :expanded, type: Boolean

  field :_id, type: String, default: ->{ board }
end

class Database
  def save(board:, parent:)

  end

  def finish
  
  end

  def next

  end

end

b = Board.new(board: 'hifsello there')

b.save rescue nil

puts Board.count
