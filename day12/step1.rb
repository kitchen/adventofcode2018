require './pots'

rules = File.readlines('input.txt')

initial_state = rules.shift.chomp.sub('initial state: ', '')
rules.shift


pots = Pots.new(initial_state, rules)
2000.times {
  pots.grow!
  puts "#{pots.generation}: #{pots.to_h.values.join('')}"
}

# puts pots.select {|k,v| v == '#'}.to_h.keys.sum
