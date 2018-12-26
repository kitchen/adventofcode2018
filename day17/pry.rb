require './fountain'

fountain = Fountain.new(File.readlines("input.txt"))


puts fountain
fountain.dump_png
require 'pry'
binding.pry

1
