require_relative 'database'
require_relative 'solver'
require 'benchmark'
require 'ruby-prof'

COLORS = {
  'A' => :red,     'I' => :red,
  'B' => :blue,    'J' => :blue,
  'C' => :green,   'K' => :green,
  'D' => :yellow,  'L' => :yellow,
  'E' => :black,   'M' => :black,
  'F' => :magenta, 'N' => :magenta,
  'G' => :cyan,    'O' => :cyan,
  'H' => :white,   'P' => :white,
  'Q' => :red,     'R' => :blue,
  'S' => :green,   'T' => :yellow,
  'U' => :black,   'V' => :magenta,
  'W' => :cyan
}

CLIMB_10 = [
            %w(# # # # # #),
            %w(# # 0 0 # #),
            %w(# A 0 0 C #),
            %w(# A A B C #),
            %w(# D U U E #),
            %w(# H U U F #),
            %w(# H G F F #),
            %w(# # # # # #)
           ].map { |array| array.map(&:ord) }.freeze

CLIMB_12 = [
            %w(# # # # # # #),
           %w(# # # 0 # # #),
           %w(# A 0 0 0 B #),
           %w(# A C C D B #),
           %w(# E C D D F #),
           %w(# F F U G G #),
           %w(# H U U U J #),
           %w(# # # # # # #)
           ].map { |array| array.map(&:ord) }.freeze

CLIMB_24 = [
         %w(# # # # # # # # #),
         %w(# # # # 0 # # # #),
         %w(# A A 0 0 0 B B #),
         %w(# C C D D D E E #),
         %w(# C C F G G E E #),
         %w(# H H F F G M M #),
         %w(# P H I J L M N #),
         %w(# P Q I K L O N #),
         %w(# Q Q R R R O O #),
         %w(# S S T U V W W #),
         %w(# S S U U U W W #),
         %w(# # # # # # # # #)
          ].map { |array| array.map(&:ord) }.freeze

# to ease the problem,
# from the perspective of next_board
# pieces can only move one space at a time
# these short moves will then be collapsed in the db.

# TODO: celluloid and ruby with native threads.
# local db buffer to prevent asking mongo for stuff so much

# require 'celluloid/autostart'


db = Database.new
db.destroy_all
db.build(Board.new(board: CLIMB_10))

puts Benchmark.measure {
  while !db.on_level?(20)
    b = db.next
    solver = Solver.new(b, colors: COLORS)
    expanded_boards = solver.next_boards
    db.builder(expanded_boards)
  end
}

# Print a graph profile to text
printer = RubyProf::GraphPrinter.new(result)
printer.print(STDOUT, {})
