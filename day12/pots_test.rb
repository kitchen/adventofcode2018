require 'minitest/autorun'
require 'minitest/assertions'

require './pots'

class PotsTest < Minitest::Test
  EXAMPLE = '#..#.#..##......###...###'

  def test_load_pots
    pots = Pots.new(EXAMPLE)
    assert_equal(EXAMPLE, pots.to_h.values.join(''))
  end
  

  def test_gap_insertion
    stuff = '##'
    pots = Pots.new(stuff)
    
    pots[-3] = '#'
    pots[3] = '#'
    pots[0] = '.'
    assert_equal('#...#.#', pots.to_h.values.join(''))
  end
  
  def test_pattern_parse
    pots = Pots.new
    
    assert_equal(['#####', '#'], pots.parse_pattern('##### => #'))
    assert_equal(['.....', '.'], pots.parse_pattern('..... => .'))
    assert_equal(['#.#.#', '#'], pots.parse_pattern('#.#.# => #'))
  end
  
  GENERATIONS = [
    '...## => #',
    '..#.. => #',
    '.#... => #',
    '.#.#. => #',
    '.#.## => #',
    '.##.. => #',
    '.#### => #',
    '#.#.# => #',
    '#.### => #',
    '##.#. => #',
    '##.## => #',
    '###.. => #',
    '###.# => #',
    '####. => #',
  ]
  
  def test_first_generation
    pots = Pots.new(EXAMPLE)
    pots.grow_string!(GENERATIONS.first)
    puts pots.to_h.values.join('')
    assert_equal(7, pots.to_h.values.count {|state| state == '#'})
  end
  
  
  
end