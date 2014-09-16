class Database
  include Mongo
  def initialize(host: '127.0.0.1', port: '27017')
    @db = Moped::Session.new(["Adams-MacBook-Pro-2.local:27017"]).db(:climb_pro)
  end

  def save(board:, parent_baord:)
    # TODO: implement
  end

  def load_next

  end
end
