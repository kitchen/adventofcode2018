require 'minitest/autorun'
require 'minitest/assertions'

require './manhattan_areas'

class ManhattanAreasTest < Minitest::Test
  EXAMPLE = [
    "1, 1",
    "1, 6",
    "8, 3",
    "3, 4",
    "5, 5",
    "8, 9", 
  ]

  def setup
    @areas = ManhattanAreas.new(EXAMPLE)
  end
  
  def test_things
    require 'pry'
    binding.pry
    

  end
end
