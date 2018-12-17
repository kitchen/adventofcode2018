require 'minitest/autorun'
require 'minitest/assertions'

require './funtree'

class FunTreeTest < Minitest::Test
  SAMPLE = %w{2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2}.freeze

  def setup
    input = SAMPLE.dup
    @node = FunTree.parse(input)
  end

  def test_parse
    input = SAMPLE.dup
    node = FunTree.parse(input)

    assert_empty(input)
    assert_equal(2, node[:children].size)
    assert_equal(3, node[:metadata].size)
    assert_equal([1,1,2], node[:metadata])
  end

  def test_sum_metadatas
    assert_equal(138, FunTree.sum_metadatas(@node))
  end

  def test_node_values
    node1 = {children: [], metadata: [10,11,12]}
    node2 = {children: [], metadata: [1,2,3]}
    assert_equal(33, FunTree.node_value(node1))
    assert_equal(6, FunTree.node_value(node2))

    node3 = {children: [node1, node2], metadata: [1,1]}
    assert_equal(66, FunTree.node_value(node3))

    node4 = {children: [node1, node2], metadata: [1,2]}
    assert_equal(39, FunTree.node_value(node4))

    node5 = {children: [node1, node2], metadata: [2,2]}
    assert_equal(12, FunTree.node_value(node5))

    node6 = {children: [node1, node2], metadata: [2,4]}
    assert_equal(6, FunTree.node_value(node6))
  end

end
