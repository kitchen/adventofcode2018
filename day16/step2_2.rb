require './registers'
require './registers'
require 'set'

register = [0,0,0,0]
File.readlines(ARGV[0]).each do |line|
  line.chomp!
  Registers.execute_instruction(register, line)
end

require 'pry'

binding.pry

1
