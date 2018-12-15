require 'set'

class ManhattanAreas
  attr_accessor :points

  def initialize(input_lines)
    @points = Set.new(input_lines.map {|line| line.chomp.split(/,\s*/).map(&:to_i)})
  end

  def self.from_file(file)
    ManhattanAreas.new(File.readlines(file))
  end

  def grid_max
    grid_max_x = points.map {|point| point[0]}.max + 1
    grid_max_y = points.map {|point| point[1]}.max + 1
    return [grid_max_x, grid_max_y]
  end

  def border_points
    return @border_points if @border_points
    @border_points = Set.new
    (max_x, max_y) = grid_max
    [0, max_y].each do |y|
      (0...max_x).each do |x|
        @border_points << [x,y]
      end
    end

    [-1, max_x].each do |x|
      (-1...max_y).each do |y|
        @border_points << [x,y]
      end
    end
    @border_points
  end

  def infinites
    return @infinites if @infinites

    @infinites = Set.new
    border_points.each do |border_point|
      nearest_point = find_nearest_point(border_point)
      if nearest_point
        @infinites << nearest_point
      end
    end

    @infinites
  end

  def find_nearest_point(point)
    @nearest_point ||= {}
    return @nearest_point[point] if @nearest_point.key?(point)
    nearest_points = find_nearest_points(point)
    if nearest_points.size > 1
      @nearest_point[point] = nil
    else
      @nearest_point[point] = nearest_points[0]
    end
  end

  def distance(point, test_point)
    (point[0] - test_point[0]).abs + (point[1] - test_point[1]).abs
  end

  def find_nearest_points(point)
    @nearest_points ||= {}
    return @nearest_points[point] if @nearest_points.key?(point)
    test_points = {}
    points.each do |test_point|
      test_points[test_point] = distance(point, test_point)
    end

    closest_distance = test_points.values.min
    @nearest_points[point] = test_points.select {|_,v| v == closest_distance }.keys
  end

  def finite_areas
    return @finite_areas if @finite_areas
    @finite_areas = Hash.new {|h,k| h[k] = Set.new }
    (max_x, max_y) = grid_max
    (0...max_x).each do |x|
      (0...max_y).each do |y|
        nearest_point = find_nearest_point([x,y])
        if nearest_point
          finite_areas[nearest_point] << [x,y]
        end
      end
    end
    infinites.each do |infinite|
      @finite_areas.delete(infinite)
    end
    @finite_areas
  end

  def safe_points(desired_sum)
    return @safe_points if @safe_points
    @safe_points = Set.new

    (max_x, max_y) = grid_max
    # factor this out into an "each point" method probably if this were for real
    (0...max_x).each do |x|
      (0...max_y).each do |y|
        sum_distance = @points.map {|point| distance(point, [x,y])}.sum
        if sum_distance < desired_sum
          @safe_points << [x,y]
        end
      end
    end

    @safe_points
  end

end
