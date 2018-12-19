class Pots
  include Enumerable

  attr_accessor :pots
  def initialize(initial_state = '')
    @pots = Hash.new {|h,k| h[k] = '.'}
    @pots = Hash[initial_state.chars.map.with_index {|state, index| [index, state]}]
  end
  
  def [](number)
    return @pots[number] if pots.key?(number)
    '.'
  end
  
  def []=(number, state)
    @pots[number] = state
  end
  
  def each(&blk)
    # this allows for gaps in the key
    ((pots.keys.min)..(pots.keys.max)).each do |number|
      yield [number, self[number]]
    end
  end
  
  def around(number)
    ((number-2)..(number+2)).map {|number| self[number]}.join('')
  end
  
  STATE_OPPOSITES = {
    '.' => '#',
    '#' => '.'
  }.freeze
  
  def opposite_of(state)
    STATE_OPPOSITES[state]
  end

  def grow!(pattern, new_state)
    changes = {}
    ((pots.keys.min - 2)..(pots.keys.max + 2)).each do |number|
      if around(number) == pattern
        changes[number] = new_state
      else
        changes[number] = opposite_of(new_state)
      end
    end
    
    @pots.merge!(changes)
  end
  
  def parse_pattern(raw_pattern)
    (_, pattern, new_state) = raw_pattern.match(/^(.{5})\s+=>\s+(.)/).to_a
    
    [pattern, new_state]
  end
  
  def grow_string!(raw_pattern)
    (pattern, new_state) = parse_pattern(raw_pattern)
    puts "pattern: #{pattern}"
    grow!(pattern, new_state)
  end
end