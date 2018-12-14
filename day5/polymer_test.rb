require 'minitest/autorun'
require 'minitest/assertions'

require './polymer'

class PolymerTest < Minitest::Test
  def test_react_fully
    polymer = "dabAcCaCBAcCcaDA"
    assert_equal('dabCBAcaDA', PolymerThing.react_fully(polymer))
  end
end
