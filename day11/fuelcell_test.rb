require 'minitest/autorun'
require 'minitest/assertions'

require './fuelcell'

class FuelCellGridTest < Minitest::Test
  def test_power_level
    assert_equal(4, FuelCellGrid.new(8).power_level(3,5), "first one")
    assert_equal(-5, FuelCellGrid.new(57).power_level(122,79), "second one")
    assert_equal(0, FuelCellGrid.new(39).power_level(217,196), "third one")
    assert_equal(4, FuelCellGrid.new(71).power_level(101,153), "fourth one")
  end

  def test_best_power_square
    assert_equal([[21,61], 30], FuelCellGrid.new(42).find_most_powerful)
  end
end
