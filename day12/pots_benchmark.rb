require 'minitest/autorun'
require 'minitest/benchmark'

require './pots'


class PotsBench < Minitest::Benchmark
  EXAMPLE = '#..#.#..##......###...###'
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

  def self.bench_range
    bench_exp(1, 100_000)
  end

  def setup
    @pots = Pots.new(EXAMPLE, RULES)
  end

  def bench_pot_grower
    assert_performance_linear do |n|
      puts "doing #{n} generations"
      n.times {@pots.grow!}
    end
  end
end
