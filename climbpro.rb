require_relative 'database'
require_relative 'solver'
require 'benchmark'

BOARD12 = [
           %w(# # 0 # #),
           %w(A 0 0 0 B),
           %w(A C C D B),
           %w(E C D D F),
           %w(F F I G G),
           %w(H I I I J),
]

BOARD = [
%w(# # # 0 # # #),
%w(A A 0 0 0 B B),
%w(C C D D D E E),
%w(C C F G G E E),
%w(H H F F G M M),
%w(P H I J L M N),
%w(P Q I K L O N),
%w(Q Q R R R O O),
%w(S S T U V W W),
%w(S S U U U W W)].freeze

# to ease the problem,
# from the perspective of next_board
# pieces can only move one space at a time
# these short moves will then be collapsed in the db.

Board.destroy_all
Board.create(contents: BOARD)

puts Benchmark.measure {
  10_000.times do
    b = Board.next
    solver = Solver.new(b)

    # puts "Expanding:"
    # solver.pp

    expanded_boards = solver.next_boards

    # puts "Found:"
    # expanded_boards.map(&:pp)

    expanded_boards.map do |nb|
      Board.build(b, nb.board)
    end
    Board.finish(b)
  end
}
