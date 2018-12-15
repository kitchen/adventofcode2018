require 'minitest/autorun'
require 'minitest/assertions'

require 'set'
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

  def test_infinites
    assert_equal(Set.new([[1,1],[1,6],[8,3],[8,9]]), @areas.infinites)
  end

  def test_find_largest_area
    assert_equal(17, @areas.finite_areas.values.map(&:size).sort.last)
  end

  def test_region_size
    assert_equal(16, @areas.safe_points(32).size)
  end
end
