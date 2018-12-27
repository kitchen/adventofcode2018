require 'minitest/autorun'
require 'minitest/benchmark'

require './lumber'

class LumberBench < Minitest::Benchmark
  def self.bench_range
    bench_exp(100, 10_000_000)
  end

  TEST_MAP = <<~EOF.strip
    .#.#...|#.
    .....#|##|
    .|..|...#.
    ..|#.....#
    #.#|||#|#|
    ...#.||...
    .|....|...
    ||...#|.#|
    |.||||..|.
    ...#.|..|.
  EOF

  def setup
    @lumber = Lumber.new(TEST_MAP)
  end

  def bench_lumber
    assert_performance_linear do |n|
      until @lumber.minute == n
        @lumber.tick!
      end
    end
  end

end
