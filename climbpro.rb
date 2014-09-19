require_relative 'database'
require_relative 'solver'
require 'benchmark'

COLORS = {
  "A" => :red,
  "B" => :blue,
  "C" => :green,
  "D" => :yellow,
  "E" => :black,
  "F" => :magenta,
  "G" => :cyan,
  "H" => :white,
  "I" => :red,
  "J" => :blue,
  "K" => :green,
  "L" => :yellow,
  "M" => :black,
  "N" => :magenta,
  "O" => :cyan,
  "P" => :white,
  "Q" => :red,
  "R" => :blue,
  "S" => :green,
  "T" => :yellow,
  "U" => :black,
  "V" => :magenta,
  "W" => :cyan,
}

CLIMB_10 = [
            %w(# # # # # #),
            %w(# # 0 0 # #),
            %w(# A 0 0 C #),
            %w(# A A B C #),
            %w(# D U U E #),
            %w(# H U U F #),
            %w(# H G F F #),
            %w(# # # # # #),
           ].freeze


CLIMB_12 = [
           %w(# # # 0 # # #),
           %w(# A 0 0 0 B #),
           %w(# A C C D B #),
           %w(# E C D D F #),
           %w(# F F U G G #),
           %w(# H U U U J #),
           %w(# # # # # # #)].freeze

CLIMB_24= [
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
         %w(# # # # # # # # #)].freeze

# to ease the problem,
# from the perspective of next_board
# pieces can only move one space at a time
# these short moves will then be collapsed in the db.

Board.destroy_all
Board.create(contents: CLIMB_10)

puts Benchmark.measure {
  10_000.times do |i|
    b = Board.next
    solver = Solver.new(b, colors: COLORS)

    # if i % 10 == 0
    #   print '.'
    # end
    puts "Expanding:"
    solver.pretty_print

    expanded_boards = solver.next_boards

    # puts "Found:"
    # expanded_boards.map(&:pretty_print)

    expanded_boards.map do |nb|
      Board.build(b, nb.board)
    end
    Board.finish(b)
  end
}
