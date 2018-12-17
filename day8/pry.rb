require './funtree'
require 'pry'

data = File.read(ARGV[0]).split(/\s+/)

node = FunTree.parse(data)

puts FunTree.sum_metadatas(node)
puts FunTree.node_value(node)

binding.pry
