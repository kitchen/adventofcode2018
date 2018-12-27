require 'minitest/autorun'
require 'minitest/assertions'

require './fountain'

class FountainTest < Minitest::Test
  def test_parse_line
    assert_equal([[495, 2], [495, 3], [495, 4], [495, 5], [495, 6], [495, 7]], Fountain.parse_line("x=495, y=2..7"))
    assert_equal([[495, 7], [496, 7], [497, 7], [498, 7], [499, 7], [500, 7], [501, 7]], Fountain.parse_line("y=7, x=495..501"))

    assert_raises(Exception) do
      Fountain.parse_line("y=7, y=495..501")
    end
  end

  TEST_SCAN = <<~EOF.split(/\n/)
    x=495, y=2..7
    y=7, x=495..501
    x=501, y=3..7
    x=498, y=2..4
    x=506, y=1..2
    x=498, y=10..13
    x=504, y=10..13
    y=13, x=498..504
  EOF

  def test_generate_png
    fountain = Fountain.new(TEST_SCAN)
    fountain.dump_png
    assert(true, "it worked")
  end

  def test_flow
    fountain = Fountain.new(TEST_SCAN)
    fountain.flow!
    assert_equal(57, fountain.water_reached)
    fountain.dump_png
    assert_equal(29, fountan.standing_water)
    assert_equal(57, fountain.water_reached)
    assert(true, "it worked")
  end



end
