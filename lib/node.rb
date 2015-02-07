# solve the climb pro puzzle 2015 Adam Hess

require 'benchmark'
require_relative './node/solver'
require_relative './node/board'
require_relative './node/constants'
require_relative './node/buffer'

class Node
  # TODO dcell me!
  def initialize
    @solver = Solver
    @buffer = Buffer.new
    @buffer.async.keep_full
    sleep 10
  end

  def solve
    @solver.new(@buffer.get).next_boards
  end
end

n = Node.new
loop do
  puts n.solve.inspect
end
