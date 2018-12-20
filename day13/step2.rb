require './minecraft'
require 'pry'

mess = Mess.new
mess.parse_map(File.readlines(ARGV[0]))
mess.annihilate = true

# puts mess

100000000.times do |i|
  puts "tick #{i}"
  mess.tick!
  # str = mess.to_s
  # puts "\e[H\e[2J" + str
  break if mess.carts.count <= 1
end

require 'pry'
binding.pry


puts 1
