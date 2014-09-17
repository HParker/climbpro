require 'mongoid'

Mongoid.load!("db/mongoid.yml", :development)

class Board
  include Mongoid::Document

  belongs_to :parent, class_name: "Board", inverse_of: :children
  has_many :children, class_name: "Board", inverse_of: :parent
  
  field :contents
  field :expanded, type: Boolean, default: false
  field :created_at, type: Time

  field :_id, default: ->{ contents.join('') } # simple for now

  def self.build parent, child
    parent = Board.find(parent.join('')) rescue nil
    Board.create(parent: parent, contents: child, created_at: Time.now) rescue nil
  end

  def self.next
    Board.where(expanded: false).asc(:create_at).first.contents
  end

  def self.finish board
    b = Board.find(board.join(''))
    b.expanded = true
    b.save
  end
end
