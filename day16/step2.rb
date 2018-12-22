require './registers'
require './registers'
require 'set'

lines = File.readlines(ARGV[0])

instruction_map = Hash.new {|h,k| h[k] = Registers::INSTRUCTIONS.to_set}
until lines.empty?
  before = lines.shift.gsub(/[^\s\d]/, '').strip
  instruction = lines.shift.chomp
  after = lines.shift.gsub(/[^\s\d]/, '').strip
  lines.shift

  instructions = Registers.find_matching_instructions(before, instruction, after)
  instruction_number = Registers.to_instruction(instruction)[0]
  instruction_map[instruction_number] = instruction_map[instruction_number] & instructions
  if instruction_map.empty?
    raise "instruction #{instruction_number} can't be anything, apparently, that's not right"
  end
end


def find_the_only(instruction_map)
  instruction_counts = Hash.new(0)
  instruction_map.each do |_, instructions|
    instructions.each do |instruction|
      instruction_counts[instruction] += 1
    end
  end
  instruction_counts
end

require 'pry'
binding.pry

1
