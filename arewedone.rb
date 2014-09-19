require "./database.rb"

while true
  sleep(30)
  puts "checking #{Board.count}"
  solutions = Board.where(:id => /#+U+#+/)
  if solutions.count > 0
    puts solutions.map(&:pretty_print)
    raise 'we done it'
  end
end
