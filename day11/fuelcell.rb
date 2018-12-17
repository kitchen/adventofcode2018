

class FuelCellGrid
  attr_accessor :serial
  attr_accessor :grid
  attr_accessor :power_squares
  attr_reader :max_x
  attr_reader :max_y

  def initialize(serial, max_x = 300, max_y = 300)
    @serial = serial
    @grid = Hash.new {|h,k| h[k] = Hash.new }
    @power_squares = Hash.new {|h,k| h[k] = Hash.new }
    @max_x = max_x
    @max_y = max_y
  end

  def power_level(x,y)
    return grid[x][y] if grid[x].key?(y)
    grid[x][y] = ((((x + 10) * y + serial) * (x + 10)) / 100) % 10 - 5
  end

  def power_square(x,y)
    return power_squares[x][y] if power_squares[x].key?(y)
    power_squares[x][y] = (x...(x+3)).map do |test_x|
      (y...(y+3)).map {|test_y| power_level(test_x, test_y)}.sum
    end.sum
  end

  def find_most_powerful
    best = nil
    best_power = nil
    (1..(max_y - 2)).each do |x|
      (1..(max_y - 2)).each do |y|
        best_power ||= power_square(x,y)
        if power_square(x,y) > best_power
          best = [x,y]
          best_power = power_square(x,y)
        end
      end
    end
    return [best, best_power]
  end
end
