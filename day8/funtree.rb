class FunTree
  # note: this modifies `data`
  def self.parse(data)
    node = {children: [], metadata: []}
    num_children = data.shift.to_i
    num_metadata = data.shift.to_i
    num_children.times do
      node[:children] << parse(data)
    end
    num_metadata.times do
      node[:metadata] << data.shift.to_i
    end
    return node
  end

  def self.sum_metadatas(node)
    node[:children].map {|child| sum_metadatas(child)}.sum + node[:metadata].sum
  end

  def self.node_value(node)
    if node[:children].empty?
      return node[:metadata].sum
    else
      node[:metadata].map do |entry|
        child = node[:children][entry - 1]
        if child
          node_value(child)
        else
          0
        end
      end.sum
    end
  end
end
