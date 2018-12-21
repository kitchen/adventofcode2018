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
    example = [ 3, 3, 3, 3]
    assert_equal([3,3,3,6], Registers.addr(example.dup, 1, 2, 3))
    assert_equal([3,3,3,5], Registers.addi(example.dup, 1, 2, 3))
    assert_equal([3,9,3,3], Registers.mulr(example.dup, 3, 2, 1))
    assert_equal([3,6,3,3], Registers.muli(example.dup, 3, 2, 1))
    assert_equal([3, 3, 3, 3], Registers.banr(example.dup, 0, 1, 2))
    assert_equal([3, 3, 1, 3], Registers.bani(example.dup, 0, 1, 2))
  end
  
  
  def test_to_register
    output = {1 => 3, 2 => 2, 3 => 2, 4 => 1}
    
    assert_equal([3,2,2,1], Registers.to_register(%w{3 2 2 1}))
    assert_equal([3,2,2,1], Registers.to_register("3 2 2 1"))
  end
end