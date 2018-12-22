require 'minitest/autorun'
require 'minitest/assertions'

require './battle'

class BattleTest < Minitest::Test

  def test_battle_order
    grid = <<~EOF
      #######
      #.G.E.#
      #E.G.E#
      #.G.E.#
      #######
    EOF

    battle = Battle.new(grid)
    assert_equal(6, battle.units)
  end
end
