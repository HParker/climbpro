require "./database.rb"

old_count = 0
while true
  sleep(30)
  count = Board.count
  puts "checking #{count} Delta: #{count - old_count}"
  old_count = count
  solutions = Board.where(:id => /#+U+#+/)
  if solutions.count > 0
    puts solutions.map(&:pretty_print)
    raise 'we done it'
  end
end
