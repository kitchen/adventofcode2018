

class FuelCellGrid
  attr_accessor :serial
  attr_accessor :grid
  attr_accessor :power_squares
  attr_reader :max_x
  attr_reader :max_y

  def initialize(serial, max_x = 300, max_y = 300)
    @serial = serial
    @grid = Hash.new {|h,k| h[k] = Hash.new }
    @power_squares = Hash.new {|h,k| h[k] = Hash.new {|h,k| h[k] = Hash.new }}
    @max_x = max_x
    @max_y = max_y
  end

  def power_level(x,y)
    return grid[x][y] if grid[x].key?(y)
    grid[x][y] = ((((x + 10) * y + serial) * (x + 10)) / 100) % 10 - 5
  end

  def power_square(x,y, size=3)
    return 0 if size == 0
    if power_squares[size][x].key?(y)
      return power_squares[size][x][y]
    end

    smaller_square = power_square(x,y,size - 1)
    x_line = (x...(x+size)).map do |test_x|
      test_y = y + size - 1
      power_level(test_x, test_y)
    end.sum

    # -1 because we don't want to count the corner twice
    y_line = (y...(y + size - 1)).map do |test_y|
      test_x = x + size - 1
      power_level(test_x, test_y)
    end.sum

    power_squares[size][x][y] = smaller_square + x_line + y_line
  end

  def find_most_powerful_size
    (1..max_x).map do |size|
      puts size
      find_most_powerful(size)
    end.max_by {|power_square| power_square[1]}
  end

  def find_most_powerful(size = 3)
    (1..(max_y - size + 1)).map do |x|
      (1..(max_y - size + 1)).map do |y|
        [[x, y], power_square(x,y,size), size]
      end.max_by {|power_square| power_square[1]}
    end.max_by {|power_square| power_square[1]}
  end
end
