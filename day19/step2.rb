require './registers'

filename = ARGV[0] || 'input.txt'
# 0	1	8	10551352	0	10551355
program = Program.new(File.readlines(filename), %w{1 0 0 0 0 0}.map(&:to_i))



loop do
  puts "#{program.registers[program.ip]}#{program.instructions[program.registers[program.ip]].join("\t")}"
  break unless program.tick!
  puts "#{program.registers[0]}\t#{program.registers[1]}\t#{program.registers[3]}\t#{program.registers[4]}\t#{program.registers[5]}"
  puts
end

puts "meanwhile, in register 0: #{program.registers[0]}"
