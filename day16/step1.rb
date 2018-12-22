require './registers'

inputs = []
three_or_more = 0

lines = File.readlines(ARGV[0])

until lines.empty?
  before = lines.shift.gsub(/[^\s\d]/, '').strip
  instruction = lines.shift.chomp
  after = lines.shift.gsub(/[^\s\d]/, '').strip
  lines.shift

  instructions = Registers.find_matching_instructions(before, instruction, after)
  three_or_more += 1 if instructions.count >= 3
end

puts "three or more #{three_or_more}"

require 'pry'
binding.pry

1
