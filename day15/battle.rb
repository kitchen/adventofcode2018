class Battle
  attr_accessor :units
  attr_accessor :grid

  attr_accessor :default_attack_power
  attr_accessor :default_hit_points

  Unit = Struct.new(:type, :number, :attack_power, :hit_points, :location)
  GridPoint = Struct.new(:type, :x, :y, :unit)

  def initialize(grid, default_hit_points: 200, default_attack_power: 3)
    @grid = Hash.new {|h,k| h[k] = {}}
    @units = {}
    @default_hit_points = default_hit_points
    @default_attack_power = default_attack_power
  end

  def parse_grid(grid)
    grid = grid.split(/\n/) if grid_lines.is_a?(String)
    unit_number = 0
    grid.each.with_index do |grid_line, y|
      grid_line.each.with_index do |what, x|
        unit = nil
        if what == 'E' || what == 'G'
          unit = Unit.new(what, unit_number, default_attack_power, default_hit_points)
        end

        grid_point = GridPoint.new(what, x, y, unit)
      end
    end
  end

  def to_s
    units.map do |line|
      line.map do |point|
        return point.unit.type if point.unit
        point.type
      end.join('')
    end.join("\n")
  end

  def each_unit(&blk)
    # sort order
  end
end
