require 'minitest/autorun'
require 'minitest/assertions'

require './cooker'

class CookerTest < Minitest::Test
  def test_sequence_generator
    expected = %w{1  0 1 0  1  2 4 5  1  5  8  9  1  6  7  7  9  2}.map!(&:to_i)
    assert_equal(expected, Cooker.generator([3,7], 2).take(18))
  end
end
