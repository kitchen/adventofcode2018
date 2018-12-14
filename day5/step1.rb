require './polymer'

polymer = File.read(ARGV[0])
polymer.chomp!

final_polymer = PolymerThing.react_fully(polymer)

puts final_polymer

require 'pry'
binding.pry
