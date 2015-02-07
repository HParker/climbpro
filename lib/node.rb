# solve the climb pro puzzle 2015 Adam Hess

require 'benchmark'
require_relative './node/solver'
require_relative './node/board'
require_relative './node/constants'
require_relative './node/buffer'


solver = Solver.new(Buffer.get)
puts solver.next_boards.inspect
