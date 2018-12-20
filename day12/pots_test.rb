require 'minitest/autorun'
require 'minitest/assertions'
require 'minitest/benchmark'

require './pots'

class PotsTest < Minitest::Test
  EXAMPLE = '#..#.#..##......###...###'

  def test_load_pots
    pots = Pots.new(EXAMPLE)
    assert_equal(EXAMPLE, pots.to_h.values.join(''))
  end

  def test_around
    pots = Pots.new(EXAMPLE)
    assert_equal('#..#.', pots.around(2))
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

  RULES = [
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

  GENERATIONS = %w{
    ...#...#....#.....#..#..#..#...........
    ...##..##...##....#..#..#..##..........
    ..#.#...#..#.#....#..#..#...#..........
    ...#.#..#...#.#...#..#..##..##.........
    ....#...##...#.#..#..#...#...#.........
    ....##.#.#....#...#..##..##..##........
    ...#..###.#...##..#...#...#...#........
    ...#....##.#.#.#..##..##..##..##.......
    ...##..#..#####....#...#...#...#.......
    ..#.#..#...#.##....##..##..##..##......
    ...#...##...#.#...#.#...#...#...#......
    ...##.#.#....#.#...#.#..##..##..##.....
    ..#..###.#....#.#...#....#...#...#.....
    ..#....##.#....#.#..##...##..##..##....
    ..##..#..#.#....#....#..#.#...#...#....
    .#.#..#...#.#...##...#...#.#..##..##...
    ..#...##...#.#.#.#...##...#....#...#...
    ..##.#.#....#####.#.#.#...##...##..##..
    .#..###.#..#.#.#######.#.#.#..#.#...#..
    .#....##....#####...#######....#.#..##.
  }

  def test_first_generation
    pots = Pots.new(EXAMPLE, RULES)
    GENERATIONS.each_with_index do |plants, index|
      generation = index + 1
      pots.grow!
      assert_equal(generation, pots.generation)
      assert_equal(plants, (-3..35).map {|i| pots[i]}.join(''), "generation #{generation}")
    end
  end
end
