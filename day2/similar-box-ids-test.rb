require 'minitest/autorun'
require 'minitest/assertions'
require './similar-box-ids'

class BoxIdsTest < Minitest::Test

  def test_checksum
    # 2s: 4, 3s: 3
    input = %w{
      abcdef 0
      bababc 2 3
      abbcde 2
      abcccd 3
      aabcdd 2
      abcdee 2
      ababab 3
    }
    assert_equal(12, SimilarBoxIds.checksum(input))

    # 2s: 4, 3s: 4
    input << "aaabbb"
    assert_equal(16, SimilarBoxIds.checksum(input))

    # 2s: 5, 3s: 5
    input << "aabccc"
    assert_equal(25, SimilarBoxIds.checksum(input))
  end

  def test_common_chars
    assert_equal('fgij', SimilarBoxIds.common_chars('fghij', 'fguij'))
    assert_equal('abc', SimilarBoxIds.common_chars('abcde', 'abcfg'))
    assert_equal('', SimilarBoxIds.common_chars('FOO', 'BAR'))
  end

  TEST_IDS = %w{
    abcde
    fghij
    klmno
    pqrst
    fguij
    axcye
    wvxyz
  }.freeze

  def test_find_diff_by
    res = SimilarBoxIds.find_diff_by(TEST_IDS, 1)
    assert_equal([
      ['fghij', 'fguij']
    ], res)

    res = SimilarBoxIds.find_diff_by(TEST_IDS, 2)
    assert_equal([
      ['abcde', 'axcye']
    ], res)

    input = %w{
      abcdefgh
      abcdefbh
      abcdqrst
      hjklmnop
    }

    assert_equal([
      ['abcdefgh', 'abcdefbh']
    ], SimilarBoxIds.find_diff_by(input, 1))


  end

end
