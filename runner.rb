class Runner
  def self.solve(board)
    board = db.next_board
    Solver.new(board).next_boards
  end

  # take a board from the db and pass it to the solver
  # then put the resulting baords back into the db.
end
