require 'minitest/autorun'
require 'minitest/assertions'

require './mydag'

class MyDagTest < Minitest::Test
  EXAMPLE = [
    "Step C must be finished before step A can begin.",
    "Step C must be finished before step F can begin.",
    "Step A must be finished before step B can begin.",
    "Step A must be finished before step D can begin.",
    "Step B must be finished before step E can begin.",
    "Step D must be finished before step E can begin.",
    "Step F must be finished before step E can begin.",
  ]

  def setup
    @dag = MyDag.from_lines(EXAMPLE)
  end

  def test_load
    assert(true, "it didn't blow up!")
  end

  def test_path
    assert_equal("CABDFE", @dag.path)
  end

  def test_work_parallel
    assert_equal(15, @dag.time_parallel(2))
  end


end
