require 'minitest/autorun'
require 'minitest/assertions'

require './marbles'

class MarblesTest < Minitest::Test
  def setup
    @emitter = Marbles.emitter
  end

  def test_sequence_generation
    assert_equal([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32], @emitter.take(23))
  end

  def test_wrapped_index
    assert_equal(1, Marbles.wrapped_index([0], 0, 2))

    dummy_board = (1..23).to_a
    assert_equal(17, Marbles.wrapped_index(dummy_board, 2, -7))
    assert_equal(0, Marbles.wrapped_index(dummy_board, 22, 2))
  end
end

class MarblesPlayerTest < Minitest::Test
  def test_games
    assert_equal(8317, MarblesPlayer.new(10).play(1618).values.max)
    assert_equal(146373, MarblesPlayer.new(13).play(7999).values.max)
    assert_equal(37305, MarblesPlayer.new(30).play(5807).values.max)
    assert_equal(54718, MarblesPlayer.new(21).play(6111).values.max)
    assert_equal(2764, MarblesPlayer.new(17).play(1104).values.max)
  end
end
