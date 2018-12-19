require 'set'
class Pots
  include Enumerable

  attr_accessor :pots
  attr_accessor :patterns
  attr_accessor :generation

  def initialize(initial_state = '', rules = [])
    @pots = Set.new
    initial_state.chars.each_with_index do |state, index|
      if state == '#'
        @pots << index
      end
    end

    @patterns = Set.new
    rules.each do |rule|
      (pattern, new_state) = parse_pattern(rule)
      if new_state == '#'
        patterns << pattern
      end
    end
    @generation = 0
  end

  def [](number)
    return '#' if @pots.include?(number)
    '.'
  end

  def []=(number, state)
    if state == '#'
      @pots << number
    else
      @pots.delete(number)
    end
  end

  def each(&blk)
    # this allows for gaps in the key
    ((pots.min)..(pots.max)).each do |number|
      yield [number, self[number]]
    end
  end

  def around(number)
    [self[number-2], self[number-1], self[number], self[number+1], self[number+2]].join('')
  end

  def grow!
    deletes = []
    adds = []
    smallest = pots.min
    biggest = pots.max

    # skip any patterns that aren't going to change the state anyways
    # hell. only test patterns that are going to make it one way or the other and assume the other otherwise
    # instead of comparing all the things, search each thing
    # break patterns into a tree
    # ..#.# => .
    # patterns['.']['.']['#']['.']['#'] = .
    # then when faced with, say... yes.
    ((smallest - 2)..(biggest + 2)).each do |number|
      if @patterns.include?(around(number))
        unless @pots.include?(number)
          adds << number
        end
      else
        if @pots.include?(number)
          deletes << number
        end
      end
    end

    # puts "#{generation}: smallest: #{smallest} #{pots.to_h.values.join('')}"
    @generation += 1
    @pots += adds
    @pots -= deletes
    @pots
  end

  def parse_pattern(raw_pattern)
    (_, pattern, new_state) = raw_pattern.match(/^(.{5})\s+=>\s+(.)/).to_a

    [pattern, new_state]
  end

end
