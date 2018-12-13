require 'minitest/autorun'
require 'minitest/assertions'

require 'set'
require './fabric'

class FabricTest < Minitest::Test
  CLAIMS = [
    "#1 @ 1,3: 4x4",
    "#2 @ 3,1: 4x4",
    "#3 @ 5,5: 2x2",
  ]

  def setup
    @fabric = Fabric.new(CLAIMS)
  end

  def test_overlaps
    assert_equal(Set.new([[3,3],[3,4],[4,3],[4,4]]),@fabric.overlaps)
  end

  def test_find_solo
    assert_equal(@fabric.claims[2], @fabric.find_solo_claim)
  end
end

class ClaimTest < Minitest::Test

  def setup
    @claim1 = Claim.new("#1 @ 1,3: 4x4")
    @claim2 = Claim.new("#2 @ 3,1: 4x4")
    @claim3 = Claim.new("#3 @ 5,5: 2x2")
  end

  def test_claim_parsing
    assert_equal("1", @claim1.id)
    assert_equal(1, @claim1.left_margin)
    assert_equal(3, @claim1.top_margin)
    assert_equal(4, @claim1.width)
    assert_equal(4, @claim1.height)
  end

  def test_coords_generation
    expected = [
      [1,3],[1,4],[1,5],[1,6],
      [2,3],[2,4],[2,5],[2,6],
      [3,3],[3,4],[3,5],[3,6],
      [4,3],[4,4],[4,5],[4,6],
    ]
    assert_equal(expected, @claim1.to_coordinate_map)
  end

  def test_overlap
    assert_equal([[3,3],[3,4],[4,3],[4,4]], @claim1.overlap(@claim2))
    assert_equal([], @claim1.overlap(@claim3))
  end

  def test_overlaps_with
    assert(@claim1.overlaps_with?(@claim2))
    refute(@claim1.overlaps_with?(@claim3))
    refute(@claim2.overlaps_with?(@claim3))
  end

end
