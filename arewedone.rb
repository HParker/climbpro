require "./database.rb"

while true
  sleep(30)
  puts :checking
  solutions = Board.where(:id => /##I##/)
  raise 'we done it' if solutions.count > 0
end