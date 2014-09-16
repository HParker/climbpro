require 'mongoid'

Mongoid.load!("db/mongoid.yml", :development)

class Board
  include Mongoid::Document

  belongs_to :parent, class_name: "Board", inverse_of: :children
  has_many :children, class_name: "Board", inverse_of: :parent
  
  field :contents
  field :expanded, type: Boolean, default: false

  field :_id, default: ->{ contents.to_s } # simple for now

  def self.build parent, child
    parent = Board.find(parent.to_s) rescue nil
    Board.create(parent: parent, contents: child) rescue nil
  end

  def self.next
    Board.where(expanded: false).first.contents
  end

  def self.finish board
    b = Board.find(board.to_s)
    b.expanded = true
    b.save
  end
end
