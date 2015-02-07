require 'json'
require 'celluloid/autostart'
require 'mongoid'
require 'dcell'

require_relative '../node/board'

DCell.start :id => "database"
Mongoid.load!("db/mongoid.yml", :development)

class DB
  include Mongoid::Document
  include Celluloid
  # belongs_to :parent, class_name: "Board", inverse_of: :children
  # has_many :children, class_name: "Board", inverse_of: :parent

  field :content
  # field :expanded, type: Boolean, default: false
  # field :created_at, type: Time

  # field :_id, default: ->{ content.join('') } # simple for now

  def write(board)
    DB.create(:content => board.rows.to_json)
  end

  def get
    puts "hey there"
    JSON.parse(DB.first.content)
    # dirty hackz
  end
end

DB.destroy_all
DB.new.write(
             Board.new([%w(# # # # # #),
              %w(# # 0 0 # #),
              %w(# A 0 0 C #),
              %w(# A A B C #),
              %w(# D U U E #),
              %w(# H U U F #),
              %w(# H G F F #),
              %w(# # # # # #)])
             )

DB.supervise_as :database
puts "Ready!"
sleep
