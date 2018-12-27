require 'digest'
class Lumber
  attr_accessor :states
  attr_accessor :max_x
  attr_accessor :max_y
  attr_accessor :minute
  def initialize(lines)
    if lines.is_a?(String)
      lines = lines.split(/\n/)
    end

    @states = {}
    @max_x = lines.first.length - 1
    @max_y = lines.count - 1
    lines.each_with_index do |line, y|
      line.chars.each_with_index do |char, x|
        @states[[x,y]] = char
      end
    end
    @minute = 0
  end

  def tick!
    new_states = {}
    states.keys.each do |(x,y)|
      new_states[[x,y]] = next_state(x,y)
    end
    @states = new_states
    @minute += 1
  end

  def next_state(x,y)
    current = states[[x,y]]
    neighbors = neighbors_of(x,y)
    case current
    when '.'
      if neighbors.count('|') >= 3
        return '|'
      else
        return '.'
      end
    when '|'
      if neighbors.count('#') >= 3
        return '#'
      else
        return '|'
      end
    when '#'
      if neighbors.count('#') >= 1 && neighbors.count('|') >= 1
        return '#'
      else
        return '.'
      end
    end
  end

  def to_s
    (0..max_y).map do |y|
      (0..max_x).map do |x|
        states[[x,y]]
      end.join('')
    end.join("\n")
  end

  def neighbors_of(point_x,point_y)
    neighbor_points = []
    ((point_x-1)..(point_x+1)).each do |x|
      ((point_y-1)..(point_y+1)).each do |y|
        neighbor_points << states[[x,y]] unless x < 0 || y < 0 || (x == point_x && y == point_y)
      end
    end

    neighbor_points
  end

  def resource_value
    states.values.count('#') * states.values.count('|')
  end

  def md5
    Digest::MD5.hexdigest(self.to_s)
  end
end
