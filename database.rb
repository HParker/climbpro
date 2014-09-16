require 'mongoid'

Mongoid.load!("db/mongoid.yml", :development)

class Board
  include Mongoid::Document

  belongs_to :parent, class_name: "Board", inverse_of: :children
  has_many :children, class_name: "Board", inverse_of: :parent
  
  field :contents, type: String
  field :expanded, type: Boolean, default: false

  field :_id, default: ->{ contents }

  def self.build parent, child
    parent = Board.find(parent) rescue nil
    Board.create(parent: parent, contents: child) rescue nil
  end

  def self.next
    Board.where(expanded: false).first.contents
  end

  def self.finish board
    b = Board.find(board)
    b.expanded = true
    puts b.save
  end
end
