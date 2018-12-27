require 'minitest/autorun'
require 'minitest/assertions'

require './lumber'

class LumberTest < Minitest::Test
  TEST_MAP = <<~EOF.strip
    .#.#...|#.
    .....#|##|
    .|..|...#.
    ..|#.....#
    #.#|||#|#|
    ...#.||...
    .|....|...
    ||...#|.#|
    |.||||..|.
    ...#.|..|.
  EOF

  def test_load_and_to_s
    lumber = Lumber.new(TEST_MAP)
    assert_equal(9, lumber.max_x)
    assert_equal(9, lumber.max_y)
    assert_equal(TEST_MAP, lumber.to_s)
  end

  def test_ticks
    lumber = Lumber.new(TEST_MAP)

    tick_1 = <<~EOF.strip
      .......##.
      ......|###
      .|..|...#.
      ..|#||...#
      ..##||.|#|
      ...#||||..
      ||...|||..
      |||||.||.|
      ||||||||||
      ....||..|.
    EOF
    lumber.tick!

    assert_equal(tick_1, lumber.to_s)

    tick_2 = <<~EOF.strip
      .......#..
      ......|#..
      .|.|||....
      ..##|||..#
      ..###|||#|
      ...#|||||.
      |||||||||.
      ||||||||||
      ||||||||||
      .|||||||||
    EOF
    lumber.tick!
    assert_equal(tick_2, lumber.to_s)

    tick_10 = <<~EOF.strip
      .||##.....
      ||###.....
      ||##......
      |##.....##
      |##.....##
      |##....##|
      ||##.####|
      ||#####|||
      ||||#|||||
      ||||||||||
    EOF
    until lumber.minute == 10
      lumber.tick!
    end

    assert_equal(tick_10, lumber.to_s)

    assert_equal(1147, lumber.resource_value)
  end



end
