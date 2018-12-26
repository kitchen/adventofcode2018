require 'set'

class Unit < Struct.new(:battle, :type, :number, :attack_power, :hit_points, :location)
  def enemies
    battle.units.values.select {|unit| type != unit.type }
  end

  def targets
    enemies.map do |enemy|
      enemy.location.non_unit_neighbors
    end.flatten.to_set
  end

  def reachable_targets
    targets.map do |target|
      [target, self.location.find_path(target, false)]
    end.select {|_, path| path }
  end

  def nearest_targets
    current_targets = reachable_targets
    min_length = current_targets.map {|_, path| path.length}.min
    current_targets.select {|_, path| path.length == min_length }
  end

  def next_target
    nearest_targets.sort_by {|target, _| [target.y, target.x] }.first
  end

  def next_move
    target = next_target
    target ? target[1].first : nil
  end

  def next_attack_target
    attack_target_location = location.unit_neighbors.select {|neighbor| neighbor.unit.type != self.type }.sort_by {|neighbor| [neighbor.unit.hit_points, neighbor.y, neighbor.x]}.first
    if attack_target_location
      attack_target_location.unit
    else
      nil
    end
  end

  def tick!
    puts "unit #{number} ticking!"
    unless self.enemies.empty?
      unless attack!
        move!
      end
    end
  end

  def attack!
    enemy = next_attack_target
    if enemy
      enemy.take_damage!(attack_power)
    end
    enemy ? true : false
  end

  def move!
    new_location = next_move
    if new_location
      old_location = location
      old_location.unit = nil
      new_location.unit = self
      self.location = new_location
    end
    attack!
  end

  def take_damage!(incoming_damage)
    self.hit_points -= incoming_damage
    if dead?
      die!
    end
    if !battle.allow_elf_deaths && type == 'E'
      # if finna_die?
      #   # raise Battle::ElfDeath.new("I'm not dead but I'll be dead before I can kill these fucks")
      # end
    end
  end

  def finna_die?
    # this is slightly flawed logic because the neighbor might have other attackers, but we'll go with it
    attackers = location.unit_neighbors.select {|neighbor| neighbor.type != 'E'}
    if attackers.empty?
      false
    else
      rounds_to_kill = (attackers.map(&:unit).map(&:hit_points).sum / attack_power)
      rounds_to_die = hit_points / (attackers.count * 3)
      if rounds_to_kill > rounds_to_die
        true
      end
    end
  end

  def die!
    self.location.unit = nil
    self.location = nil
    self.battle.units.delete(self.number)
    raise Battle::ElfDeath.new("elf died!") if type == 'E' && !battle.allow_elf_deaths
  end

  def dead?
    self.hit_points <= 0
  end

  def inspect
    "<Unit #{number}: #{type} (#{location.x}, #{location.y}) -> #{hit_points}>"
  end
end

class GridPoint < Struct.new(:type, :x, :y, :unit, :neighbors)
  def sorted_neighbors
    neighbors.sort_by {|neighbor| [neighbor.y, neighbor.x]}
  end

  def unit_neighbors
    neighbors.select(&:unit)
  end

  def sorted_unit_neighbors
    unit_neighbors.sort_by {|neighbor| [neighbor.y, neighbor.x]}
  end

  def non_unit_neighbors
    neighbors.reject(&:unit)
  end

  def sorted_non_unit_neighbors
    non_unit_neighbors.sort_by {|neighbor| [neighbor.y, neighbor.x]}
  end

  def manhattan_distance(finish)
    (self.x - finish.x).abs + (self.y - finish.y).abs
  end

  def find_path(finish, ignore_units = true)
    neighbors = ignore_units ? neighbors : non_unit_neighbors
    return [finish] if neighbors.include?(finish)

    paths_from_neighbors = neighbors.map do |neighbor|
      neighbor.bfs_path_to(finish, ignore_units)
    end

    paths_what_exist = paths_from_neighbors.reject(&:nil?)
    paths_what_exist.sort_by do |path|
      [path.count, path.first.y, path.first.x]
    end.first
  end

  # optimization: have this take a list of targets and find paths to all of them
  def bfs_path_to(finish, ignore_units = true)
    open_set = Hash.new {|h,k| h[k] = []}
    closed_set = Set.new
    meta = {}
    root = self
    distance = 0
    meta[root] = nil
    open_set[distance] << root
    closed_set << root
    found = false
    paths = []

    chosen_path = nil
    until found || open_set.values.all?(&:empty?)
      until open_set[distance].empty?
        current_node = open_set[distance].shift

        neighbors = ignore_units ? current_node.neighbors : current_node.non_unit_neighbors
        neighbors.each do |neighbor|
          meta[neighbor] = current_node unless meta.key?(neighbor)
          if neighbor == finish
            meta[neighbor] = current_node
            found = true
            paths << bfs_reconstruct_path(neighbor, meta)
          end
          open_set[distance+1] << neighbor unless closed_set.include?(neighbor)
          closed_set << neighbor
        end
      end
      distance += 1

      if found
        chosen_path = paths.sort_by {|path| [path.last.y, path.last.x]}.first
      end
    end
    chosen_path
  end

  def bfs_reconstruct_path(finish, meta)
    path = [finish]
    current_node = finish
    while current_node do
      current_node = meta[current_node]
      if current_node
        path << current_node
      end
    end
    # path.pop
    path.reverse
  end

  def path_to(finish, ignore_units = true)
    closed_set = Set.new
    open_set = Set.new
    open_set << self
    came_from = {}
    g_score = Hash.new {|h,k| h[k] = Float::INFINITY }
    g_score[self] = 0
    f_score = Hash.new {|h,k| h[k] = Float::INFINITY }
    f_score[self] = self.manhattan_distance(finish)
    g_shortest = Float::INFINITY

    until open_set.empty?
      current = open_set.sort_by {|point| f_score[point]}.first # , point.y, point.x]
      return reconstruct_path(came_from, current) if current == finish

      open_set.delete(current)
      closed_set << current

      current_neighbors = ignore_units ? current.sorted_neighbors : current.sorted_non_unit_neighbors
      current_neighbors.each do |neighbor|
        next if closed_set.include?(neighbor)

        tentative_g_score = g_score[current] + 1
        if !open_set.include?(neighbor)
          open_set << neighbor
        elsif tentative_g_score >= g_score[neighbor]
          next
        end

        came_from[neighbor] = current
        g_score[neighbor] = tentative_g_score
        f_score[neighbor] = g_score[neighbor] + current.manhattan_distance(finish)
      end
    end
    return nil
  end

  def reconstruct_path(came_from, current)
    total_path = [current]
    while came_from.key?(current)
      current = came_from[current]
      total_path << current
    end
    total_path.pop
    total_path.reverse
  end

  def inspect
    "<GridPoint[#{x},#{y}], #{unit ? unit.type : type}, #{neighbors.count}>"
  end

  def to_s
    unit ? unit.type : type
  end
end


class Battle
  class ElfDeath < Exception; end
  attr_accessor :units
  attr_accessor :grid

  attr_accessor :default_elf_attack_power
  attr_accessor :default_hit_points
  attr_accessor :round
  attr_accessor :full_rounds_completed
  attr_accessor :allow_elf_deaths

  def initialize(grid, default_elf_attack_power: 3)
    @grid = Hash.new {|h,k| h[k] = {}}
    @units = {}
    @default_hit_points = 200
    @default_elf_attack_power = default_elf_attack_power
    parse_grid(grid)
    @round = 0
    @full_rounds_completed = 0
    @allow_elf_deaths = true
  end

  def parse_grid(grid_lines)
    grid_lines = grid_lines.split(/\n/) if grid_lines.is_a?(String)
    unit_number = 0
    grid_lines.each.with_index do |grid_line, y|
      grid_line.chomp.chars.each.with_index do |what, x|
        unit = nil
        if what == 'E' || what == 'G'
          unit = Unit.new(self, what, unit_number, 3, default_hit_points)
          unit.attack_power = default_elf_attack_power if what == 'E'
          units[unit_number] = unit
          what = '.'
          unit_number += 1
        end

        grid_point = GridPoint.new(what, x, y, unit, Set.new)
        if unit
          unit.location = grid_point
        end

        if what == '.'
          west_maybe = get_location(x-1, y)
          west = west_maybe if west_maybe && west_maybe.type != '#'
          if west
            west.neighbors << grid_point
            grid_point.neighbors << west
          end

          north_maybe = get_location(x, y-1)
          north = north_maybe if north_maybe && north_maybe.type != '#'
          if north
            north.neighbors << grid_point
            grid_point.neighbors << north
          end
        end
        grid[y][x] = grid_point
      end
    end
  end

  def get_location(x,y)
    if self.grid.key?(y)
      if self.grid[y].key?(x)
        self.grid[y][x]
      end
    end
  end

  def to_s
    text_grid_with_points
    grid.values.map do |line|
      line.values.join('')
    end.join("\n")
  end

  def text_grid_with_points(points = [], mark_with = '®')
    grid.values.map do |line|
      line.values.map {|point| points.include?(point) ? mark_with : point.unit ? point.unit.type : point.type}.join('')
    end.join("\n")
  end

  def sorted_units
    units.values.sort_by {|unit| [unit.location.y, unit.location.x]}
  end

  def tick!
    raise "we're done but tick got called!? #{self.round}" if finished?
    self.round += 1
    puts "starting round #{round}"
    sorted_units.each do |unit|
      return if finished?
      next if unit.dead?
      unit.tick!
    end
    self.full_rounds_completed += 1
  end

  def play!
    loop do
      self.tick!
      break if finished?
    end
  end

  def finished?
    self.units.values.first.enemies.count == 0
  end

  def outcome
    raise "battle hasn't finished!" unless finished?
    self.units.values.map(&:hit_points).sum * self.full_rounds_completed
  end

  def victors
    raise "battle hasn't finished!" unless finished?
    self.units.values.first.type
  end
end

class Battler
  def self.find_elf_attack_power(start, grid)
    attack_power = start
    battle = nil

    # optimization idea: skip ones we know they're going to lose. we can guess this easy.
    # But I also think that those will exit really early anyways so probably won't be a big deal
    loop do
      print "trying #{attack_power} ... "
      begin
        battle = Battle.new(grid, default_elf_attack_power: attack_power)
        battle.allow_elf_deaths = false
        battle.play!
      rescue Battle::ElfDeath => e
        puts "nope! died during #{battle.round}"
        attack_power += 1
        next
      end
      puts "YES!"
      break
    end
    battle
  end
end
