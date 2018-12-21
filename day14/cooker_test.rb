require 'minitest/autorun'
require 'minitest/assertions'

require './cooker'

class CookerTest < Minitest::Test
  def test_sequence_generator
    expected = %w{1  0 1 0  1  2 4 5  1  5  8  9  1  6  7  7  9  2}.map!(&:to_i)
    actual = []
    assert_equal(expected, Cooker.generator([3,7], 2).take(18))
  end
  
  def test_next_ten
    assert_equal('0124515891', Cooker.next_ten([3,7], 2, 5))
    assert_equal('9251071085', Cooker.next_ten([3,7], 2, 18))
    assert_equal('5941429882', Cooker.next_ten([3,7], 2, 2018))
  end
  
  def test_first_appears
    assert_equal(9, Cooker.first_appears('51589'))
    assert_equal(5, Cooker.first_appears('01245'))
    assert_equal(18, Cooker.first_appears('92510'))
    assert_equal(2018, Cooker.first_appears('59414'))
  end
end
