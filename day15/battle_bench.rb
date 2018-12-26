require 'minitest/autorun'
require 'minitest/benchmark'

require './battle'

class BattleBench < Minitest::Benchmark
  def self.bench_range
    bench_exp(1, 100_000)
  end
end
