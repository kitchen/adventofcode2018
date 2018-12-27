require 'chunky_png'

class Fountain
  attr_accessor :grid
  attr_accessor :min_x
  attr_accessor :min_y
  attr_accessor :max_x
  attr_accessor :max_y

  def get_location(x, y)
    return grid[y][x]
  end

  def set_location(x, y, what)
    grid[y][x] = what
  end

  def initialize(input)
    @grid = Hash.new {|h,k| h[k] = {} }
    @min_x = @max_x = @max_y = nil
    input_lines = input.is_a?(String) ? File.readlines(input) : input
    input_lines.each do |line|
      points = self.class.parse_line(line)
      points.each do |(x, y)|
        puts "#{x} #{y}"
        set_location(x, y, '#')
        if !@min_x || x < @min_x
          @min_x = x
        elsif !@max_x || x > @max_x
          @max_x = x
        elsif !@min_y || y < @min_y
          @min_y = y
        elsif !@max_y || y > @max_y
          @max_y = y
        end
      end
    end

    # a little padding around the x edges
  end

  LINE_REGEX = %r{
    ((x=(?<x>\d+))|(y=(?<y>\d+)))
    ,\s
    ((x=(?<x>[\d\.]+))|(y=(?<y>[\d\.]+)))
  }x

  RANGE_REGEX = %r{
    (?<from>\d+)\.\.(?<to>\d+)
  }x

  def self.parse_line(line)

    range_regex = %r{}

    matches = line.match(LINE_REGEX)
    x = matches[:x]
    y = matches[:y]
    raise "invalid format" unless x && y

    ret = nil
    if x_matches = x.match(RANGE_REGEX)
      ret = (x_matches[:from]..x_matches[:to]).map {|x| [x.to_i,y.to_i]}
    elsif y_matches = y.match(RANGE_REGEX)
      ret = (y_matches[:from]..y_matches[:to]).map {|y| [x.to_i,y.to_i]}
    end

    ret
  end

  def to_s
    (-1..max_y).map do |y|
      (min_x..max_x).map do |x|
        grid[y][x] || '.'
      end.join("")
    end.join("\n")
  end

  def to_png
    # this should put a 10px margin around the whole shebang
    x_offset = min_x - 10
    y_offset = -10
    width = max_x - min_x + 20
    height = max_y + 20

    img = ChunkyPNG::Image.new(width, height, ChunkyPNG::Color('white'))
    (-2..(max_y+2)).map do |y|
      ((min_x-2)..(max_x+2)).map do |x|
        point = get_location(x, y)
        if point
          color = nil
          color = case point
          when '#'
            'black'
          when '+'
            'blue'
          when '|'
            if y < min_y || y > max_y
              'blue'
            else
              'red'
            end
          else
            require 'pry'
            binding.pry
          end

          puts "setting #{x - x_offset}, #{y - y_offset} (#{x} #{y}) to #{color}"
          img[x - x_offset, y - y_offset] = ChunkyPNG::Color(color)
        end
      end.join("")
    end.join("\n")

    # img[500 - x_offset, 0 - y_offset] = ChunkyPNG::Color('red')
    img
  end

  def dump_png(filename = '/tmp/dump.png')
    File.open(filename, 'w') do |file|
      file.write(to_png)
    end
  end

  def flow!(from_x = 500, from_y = 0)
    spread_down(from_x, from_y + 1)
  end

  # for each of these, x, y is where the spread is coming *from*
  def spread_down(x, y)
    if get_location(x, y) == '#'
      return true
    end

    if get_location(x, y) == '|'
      check_x = x
      contained_left = false
      loop do
        check_x = check_x - 1
        check_location = get_location(check_x, y)
        if check_location == '#'
          contained_left = true
          break
        elsif check_location != '|'
          break
        end
      end

      check_x = x
      contained_right = false
      loop do
        check_x = check_x + 1
        check_location = get_location(check_x, y)
        if check_location == '#'
          contained_right = true
          break
        elsif check_location != '|'
          break
        end
      end
      return contained_left && contained_right
    end

    puts "flowing down to #{x} #{y}"

    if y > max_y
      return false
    end

    set_location(x, y, '|')

    if spread_down(x, y + 1)
      left_blocked = spread_left(x - 1, y)
      right_blocked = spread_right(x + 1, y)
      return left_blocked && right_blocked
    end

    return false
  end

  def spread_left(x, y)
    if get_location(x, y) == '#'
      return true
    end

    puts "flowing left to #{x} #{y}"

    @min_x = x if x < @min_x
    set_location(x, y, '|')

    down_blocked = spread_down(x, y + 1)
    if down_blocked
      return spread_left(x - 1, y)
    else
      return false
    end
  end

  def spread_right(x, y)
    if get_location(x, y) == '#'
      return true
    end

    puts "flowing right to #{x} #{y}"
    @max_x = x if x > @max_x

    set_location(x, y, '|')

    down_blocked = spread_down(x, y + 1)
    if down_blocked
      return spread_right(x + 1, y)
    else
      return false
    end
  end

  def convert_to_standing
    to_convert = Set.new
    grid.each do |y, row|
      row.each do |x, point|
        if point == '|' && !to_convert.include?([x,y])
          check_bounds(x, y, to_convert)
        end
      end
    end
    to_convert.each do |(x,y)|
      set_location(x, y, '~')
    end
  end

  def check_bounds(x, y, seen)
    puts "checking bounds of #{x} #{y}"
    points = [[x,y]]
    check_x = x
    loop do
      check_x = check_x - 1
      location = get_location(check_x, y)
      puts "checking left #{check_x} #{y} (#{location})"
      if location == '#'
        break
      elsif location != '|'
        return false
      end
      points << location
    end

    check_x = x
    loop do
      check_x = check_x + 1
      location = get_location(check_x, y)
      puts "checking right #{check_x} #{y} (#{location})"

      if location == '#'
        break
      elsif location != '|'
        return false
      end
      points << location
    end

    seen.merge(points)
  end

  def water_reached
    (min_y..max_y).map do |y|
      grid[y].values.count {|value| value == '~' || value == '|'}
    end.sum
  end

  def standing_water
    convert_to_standing
    (min_y..max_y).map do |y|
      grid[y].values.count('~')
    end.sum
  end

end
