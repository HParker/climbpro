require_relative 'solver'
require 'benchmark'

BOARD = [
%w(I I I 0 I I I),
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

puts Solver.new(BOARD).next_boards.map(&:pp)

# puts Benchmark.measure {
#   10_000.times do
#     Solver.new(BOARD).next_boards
#  end
#}
