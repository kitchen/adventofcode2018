require 'minitest/autorun'
require 'minitest/assertions'
require 'minitest/benchmark'

require './marbles'

class MarblesTest < Minitest::Test
  def setup
    @emitter = Marbles.emitter
  end

  def test_sequence_generation
    assert_equal([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32], @emitter.take(23))
    assert_equal([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,32,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,63,0,0,0,0,0,0,0,0,0,0,0,0,0,0], @emitter.take(60))
  end
end

class MarblesPlayerTest < Minitest::Test
  def test_games
    assert_equal(8317, MarblesPlayer.new(10).play(1618).values.max)
    assert_equal(146373, MarblesPlayer.new(13).play(7999).values.max)
    assert_equal(37305, MarblesPlayer.new(30).play(5807).values.max)
    assert_equal(54718, MarblesPlayer.new(21).play(6111).values.max)
    assert_equal(2764, MarblesPlayer.new(17).play(1104).values.max)
    assert_equal(375414, MarblesPlayer.new(459).play(71320).values.max)
    # next test is pretty slow
    # assert_equal(3168033673, MarblesPlayer.new(459).play(7132000).values.max)
  end
end


class MarbleEmitterBenchmark < Minitest::Benchmark
  def self.bench_range
    bench_exp(100, 10000000)
  end

  def bench_emitter
    assert_performance_linear do |n|
      Marbles.emitter.take(n)
    end
  end
end
