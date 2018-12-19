require './pots'

rules = File.readlines(ARGV[0])

initial_state = rules.shift.chomp.sub('initial state: ', '')
rules.shift


pots = Pots.new(initial_state, rules)

prev = 0
while true
  pots.grow!
  puts "#{pots.generation} (#{pots.pots.sum} - #{prev} = #{pots.pots.sum - prev}): #{pots.to_h.values.join('')}"
  prev = pots.pots.sum
end
