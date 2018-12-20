require './minecraft'
require 'pry'

mess = Mess.new
mess.parse_map(File.readlines(ARGV[0]))

require 'pry'
binding.pry


puts 1
