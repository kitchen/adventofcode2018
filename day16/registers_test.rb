require 'set'

require 'minitest/autorun'
require 'minitest/assertions'

require './registers'
class RegistersTest < Minitest::Test
  def test_find_matching_instructions
    before = "3 2 1 1"
    after = "3 2 2 1"
    instruction = "9 2 1 2"

    matches = Registers.find_matching_instructions(before, instruction, after)
    assert_equal(%i{mulr addi seti}.to_set, matches.to_set)
  end

  def test_register_functions
    example = [3, 3, 3, 3]
    assert_equal([3,3,3,6], Registers.addr(example.dup, 1, 2, 3))
    assert_equal([3,3,3,5], Registers.addi(example.dup, 1, 2, 3))
    assert_equal([3,9,3,3], Registers.mulr(example.dup, 3, 2, 1))
    assert_equal([3,6,3,3], Registers.muli(example.dup, 3, 2, 1))
    assert_equal([3, 3, 3, 3], Registers.banr(example.dup, 0, 1, 2))
    assert_equal([3, 3, 1, 3], Registers.bani(example.dup, 0, 1, 2))
    assert_equal([3, 3, 3, 3], Registers.borr(example.dup, 2, 1, 0))
    assert_equal([11, 3, 3, 3], Registers.bori(example.dup, 2, 8, 0))
    assert_equal([3, 3, 3, 3], Registers.setr(example.dup, 2, 123, 3))
    assert_equal([3, 3, 3, 123], Registers.seti(example.dup, 123, 123, 3))
    assert_equal([1, 3, 3, 3], Registers.gtir(example.dup, 123, 2, 0))
    assert_equal([0, 3, 3, 3], Registers.gtri(example.dup, 2, 123, 0))
    assert_equal([0, 3, 3, 3], Registers.gtrr(example.dup, 1, 3, 0))
    assert_equal([1, 3, 3, 3], Registers.eqir(example.dup, 3, 1, 0))
    assert_equal([0, 3, 3, 3], Registers.eqri(example.dup, 3, 1, 0))
    assert_equal([1,3,3,3], Registers.eqrr(example.dup, 3, 2, 0))
  end


  def test_to_register
    output = {1 => 3, 2 => 2, 3 => 2, 4 => 1}

    assert_equal([3,2,2,1], Registers.to_register(%w{3 2 2 1}))
    assert_equal([3,2,2,1], Registers.to_register("3 2 2 1"))
  end
end
