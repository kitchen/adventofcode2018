require './mydag'

dag = MyDag.from_file('input.txt', 60)
require 'pry'
binding.pry
