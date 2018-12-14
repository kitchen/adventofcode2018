require './polymer'

polymer = File.read(ARGV[0])
polymer.chomp!

polymers = ('A'..'Z').map do |burninated|
  local_polymer = polymer

  output = PolymerThing.react_fully(local_polymer.delete("#{burninated}#{burninated.downcase}"))
  puts "#{burninated} #{output.length}"
  output
  #puts "#{local_polymer} #{output.length} #{output}"
end
  

require 'pry'
binding.pry

