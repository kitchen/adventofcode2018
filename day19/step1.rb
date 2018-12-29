require './registers'

filename = ARGV[0] || 'input.txt'
program = Program.new(File.readlines(filename))
program.run!

puts "meanwhile, in register 0: #{program.registers[0]}"
