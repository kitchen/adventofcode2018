require 'minitest/autorun'
require 'minitest/benchmark'

require './cooker'

class CookerBench < Minitest::Benchmark
  def self.bench_range
    bench_exp(1, 100_000)
  end

  def bench_cooker
    assert_performance_linear do |n|
      Cooker.generator([3,7], 2).take(n)
    end
  end

end