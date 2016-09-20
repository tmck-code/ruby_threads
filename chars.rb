start = "\u2500"
finish = "\u257F"

current = start
loop do

  puts current.encode('utf-8')
  current = (current.ord + 1)
  break if current.ord == finish.ord
end
