require 'minitest/autorun'
require 'minitest/assertions'

require './battle'

class BattleTest < Minitest::Test

  SIMPLE_GRID = <<~EOF
    #######
    #.G.E.#
    #E.G.E#
    #.G.E.#
    #.....#
    #######
  EOF

  def test_battle_order
    battle = Battle.new(SIMPLE_GRID)
    assert_equal(7, battle.units.count)
    assert_equal(battle.get_location(2,1).unit, battle.sorted_units.first)
    assert_equal(battle.get_location(4,3).unit, battle.sorted_units.last)
  end

  def test_reading_order_neighbors
    battle = Battle.new(SIMPLE_GRID)
    point = battle.get_location(2,2)

    north = battle.get_location(2,1)
    west = battle.get_location(1,2)
    east = battle.get_location(3,2)
    south = battle.get_location(2,3)

    # failures of this are *really* ugly, because it spits out a very deeply nested struct which I think actually contains the entire graph from that point
    # and now they're much better since I've given GridPoint an inspect method :)
    assert_equal([north, west, east, south], point.sorted_neighbors)

    test_point = battle.get_location(3,4)
    assert_equal(3, test_point.sorted_non_unit_neighbors.count)
    assert_equal(0, test_point.sorted_unit_neighbors.count)
  end

  LESS_SIMPLE_GRID = <<~EOF
    #######
    #E..G.#
    #...#.#
    #.G.#G#
    #######
  EOF

  def test_unit_things
    battle = Battle.new(LESS_SIMPLE_GRID)
    starting_unit = battle.sorted_units.first
    assert_equal(4, battle.units.count)

    enemies = starting_unit.enemies
    assert_equal(3, enemies.count)

    targets = starting_unit.targets
    assert_equal(6, targets.count)

    reachable_targets = starting_unit.reachable_targets
    refute_nil(reachable_targets)
    assert_equal(4, reachable_targets.count)

    nearest_targets = starting_unit.nearest_targets
    refute_nil(nearest_targets)
    assert_equal(3, nearest_targets.count)

    assert_equal(battle.get_location(3,1), starting_unit.next_target[0])
    assert_equal(battle.get_location(2,1), starting_unit.next_move)

  end


  PATHFINDING_TEST_GRID = <<~EOF
    ############
    #........E.#
    #.##########
    #...G......#
    #..........#
    #E........G#
    #..........#
    #...G......#
    ##########.#
    #.E........#
    ############
    #.G........#
    ##########E#
    #..E.......#
    ############
  EOF

  def test_pathfinding
    battle = Battle.new(PATHFINDING_TEST_GRID)

    assert_equal(9, battle.units.count)
    (elf1, goblin1, elf2, goblin2, goblin3, elf3, goblin4, elf4, elf5) = battle.units.values

    # just check that there are paths or not
    refute_nil(elf1.location.path_to(battle.grid[3][2]))
    assert_nil(elf1.location.path_to(battle.grid[13][5]))

    # test whether units can block or not
    # elf4 should block the path from goblin4 to elf5
    refute_nil(goblin4.location.path_to(battle.grid[13][4]))
    assert_nil(goblin4.location.path_to(battle.grid[13][4], false))

    assert_equal(battle.grid[3][3], goblin1.next_move)
    assert_equal(battle.grid[1][8], elf1.next_move)

    assert_equal(battle.grid[4][1], elf2.next_move)
    assert_nil(elf5.next_move)

  end

  def test_pathfinding_more
    grid = <<~EOF
      #######
      #.E...#
      #.....#
      #...G.#
      #######
    EOF

    battle = Battle.new(grid)
    assert_equal(2, battle.units.count)
    elf = battle.units.values.first
    assert_equal(3, elf.targets.length)
    assert_equal(3, elf.reachable_targets.length)

    nearest_targets = elf.nearest_targets
    assert_equal(2, nearest_targets.length)
    assert_equal(3, nearest_targets[0][1].length)

    assert_equal(battle.grid[2][4], elf.next_target[0])
    assert_equal(battle.grid[elf.location.y][elf.location.x + 1], elf.next_move)
  end

  CONVERGE_GRID = <<~EOF
    #########
    #G..G..G#
    #.......#
    #.......#
    #G..E..G#
    #.......#
    #.......#
    #G..G..G#
    #########
  EOF


  def test_actually_moving

    battle = Battle.new(CONVERGE_GRID)
    assert_equal(9, battle.units.count)

    elf = battle.units.values.find {|unit| unit.type == 'E' }
    assert_equal(battle.grid[2][4], elf.next_target[0])

    battle.tick!

    battle_move_1 = <<~EOF
      #########
      #.G...G.#
      #...G...#
      #...E..G#
      #.G.....#
      #.......#
      #G..G..G#
      #.......#
      #########
    EOF

    assert_equal(battle_move_1.strip, battle.to_s)

    # $debug = true
    battle.tick!



    battle_move_2 = <<~EOF
      #########
      #..G.G..#
      #...G...#
      #.G.E.G.#
      #.......#
      #G..G..G#
      #.......#
      #.......#
      #########
    EOF

    assert_equal(battle_move_2.strip, battle.to_s)

    battle.tick!
    battle_move_3 = <<~EOF
      #########
      #.......#
      #..GGG..#
      #..GEG..#
      #G..G...#
      #......G#
      #.......#
      #.......#
      #########
    EOF

    assert_equal(battle_move_3.strip, battle.to_s)
    battle.tick!
    assert_equal(battle_move_3.strip, battle.to_s)

  end

  def test_figure_out_movement_bug
    battle = Battle.new(CONVERGE_GRID)
    (goblin1, goblin2, goblin3, goblin4, elf) = battle.units.values
    goblin1.move!

    assert_equal(battle.get_location(2,1), goblin1.location)
    assert_equal(goblin1, battle.get_location(2,1).unit)
    assert_nil(battle.get_location(1,1).unit)
    goblin2.move!
    goblin3.move!
    goblin4.move!
    assert_equal(battle.get_location(4,3), elf.next_move)

  end

  FULL_BATTLE_STARTING_GRID = <<~EOF
    #######
    #.G...#
    #...EG#
    #.#.#G#
    #..G#E#
    #.....#
    #######
  EOF

  FULL_BATTLE_ENDING_GRID = <<~EOF
    #######
    #G....#
    #.G...#
    #.#.#G#
    #...#.#
    #....G#
    #######
  EOF

  def test_full_battle

    battle = Battle.new(FULL_BATTLE_STARTING_GRID)
    (goblin1, elf1, goblin2, goblin3, goblin4, elf2) = battle.units.values
    assert(battle.units.all? {|_, unit| unit.hit_points == 200 })

    battle_first_tick = <<~EOF
      #######
      #..G..#
      #...EG#
      #.#G#G#
      #...#E#
      #.....#
      #######
    EOF

    battle.tick!
    assert_equal(battle_first_tick.strip, battle.to_s)
    assert_equal(200, goblin1.hit_points)
    assert_equal(197, elf1.hit_points)
    assert_equal(197, goblin2.hit_points)
    assert_equal(197, goblin3.hit_points)
    assert_equal(200, goblin4.hit_points)
    assert_equal(197, elf2.hit_points)

    battle_second_tick = <<~EOF
      #######
      #...G.#
      #..GEG#
      #.#.#G#
      #...#E#
      #.....#
      #######
    EOF
    battle.tick!
    assert_equal(battle_second_tick.strip, battle.to_s)
    assert_equal(200, goblin1.hit_points)
    assert_equal(200, goblin4.hit_points)
    assert_equal(188, elf1.hit_points)
    assert_equal(194, goblin2.hit_points)
    assert_equal(194, goblin3.hit_points)
    assert_equal(194, elf2.hit_points)

    21.times {battle.tick!}
    round_23_grid = <<~EOF
      #######
      #...G.#
      #..G.G#
      #.#.#G#
      #...#E#
      #.....#
      #######
    EOF

    assert_equal(round_23_grid.strip, battle.to_s)
    assert_equal(5, battle.units.count)
    assert_equal(200, goblin1.hit_points)
    assert_equal(200, goblin4.hit_points)
    assert_equal(131, goblin2.hit_points)
    assert_equal(131, goblin3.hit_points)
    assert_equal(131, elf2.hit_points)

    battle.tick!
    round_24_grid = <<~EOF
      #######
      #..G..#
      #...G.#
      #.#G#G#
      #...#E#
      #.....#
      #######
    EOF

    assert_equal(round_24_grid.strip, battle.to_s)
    assert_equal(200, goblin1.hit_points)
    assert_equal(131, goblin2.hit_points)
    assert_equal(200, goblin4.hit_points)
    assert_equal(128, goblin3.hit_points)
    assert_equal(128, elf2.hit_points)

    battle.tick!
    round_25_grid = <<~EOF
      #######
      #.G...#
      #..G..#
      #.#.#G#
      #..G#E#
      #.....#
      #######
    EOF

    assert_equal(round_25_grid.strip, battle.to_s)
    assert_equal(125, goblin3.hit_points)
    assert_equal(125, elf2.hit_points)

    battle.tick!
    round_26_grid = <<~EOF
      #######
      #G....#
      #.G...#
      #.#.#G#
      #...#E#
      #..G..#
      #######
    EOF

    assert_equal(round_26_grid.strip, battle.to_s)
    assert_equal(122, goblin3.hit_points)
    assert_equal(122, elf2.hit_points)

    battle.tick!
    round_27_grid = <<~EOF
      #######
      #G....#
      #.G...#
      #.#.#G#
      #...#E#
      #...G.#
      #######
    EOF
    assert_equal(round_27_grid.strip, battle.to_s)
    assert_equal(119, goblin3.hit_points)
    assert_equal(119, elf2.hit_points)

    battle.tick!
    round_28_grid = <<~EOF
      #######
      #G....#
      #.G...#
      #.#.#G#
      #...#E#
      #....G#
      #######
    EOF
    assert_equal(round_28_grid.strip, battle.to_s)
    assert_equal(116, goblin3.hit_points)
    assert_equal(113, elf2.hit_points)
    assert_equal(200, goblin4.hit_points)

    19.times { battle.tick! }
    round_47_grid = <<~EOF
      #######
      #G....#
      #.G...#
      #.#.#G#
      #...#.#
      #....G#
      #######
    EOF

    assert_equal(FULL_BATTLE_ENDING_GRID.strip, battle.to_s)
    assert_equal(200, goblin1.hit_points)
    assert_equal(131, goblin2.hit_points)
    assert_equal(59, goblin3.hit_points)
    assert_equal(200, goblin4.hit_points)

  end

  def test_play_it_through
    battle = Battle.new(FULL_BATTLE_STARTING_GRID)
    battle.play!
    assert_equal(FULL_BATTLE_ENDING_GRID.strip, battle.to_s)
    assert_equal(47, battle.round)
    assert_equal(590, battle.units.values.map(&:hit_points).sum)
    assert_equal(27730, battle.outcome)
  end

  BATTLE_1_INITIAL = <<~EOF
    #######
    #G..#E#
    #E#E.E#
    #G.##.#
    #...#E#
    #...E.#
    #######
  EOF

  def test_battle_1
    final = <<~EOF
      #######
      #...#E#
      #E#...#
      #.E##.#
      #E..#E#
      #.....#
      #######
    EOF

    battle = Battle.new(BATTLE_1_INITIAL)
    battle.play!
    assert_equal(37, battle.full_rounds_completed)
    assert_equal(36334, battle.outcome)
    assert_equal('E', battle.victors)
  end

  BATTLE_2_INITIAL = <<~EOF
    #######
    #E..EG#
    #.#G.E#
    #E.##E#
    #G..#.#
    #..E#.#
    #######
  EOF

  def test_battle_2
    final = <<~EOF
      #######
      #.E.E.#
      #.#E..#
      #E.##.#
      #.E.#.#
      #...#.#
      #######
    EOF

    battle = Battle.new(BATTLE_2_INITIAL)
    battle.play!
    assert_equal(46, battle.full_rounds_completed)
    assert_equal(39514, battle.outcome)
    assert_equal('E', battle.victors)
  end


  BATTLE_3_INITIAL = <<~EOF
    #######
    #E.G#.#
    #.#G..#
    #G.#.G#
    #G..#.#
    #...E.#
    #######
  EOF
  def test_battle_3
    final = <<~EOF
      #######
      #G.G#.#
      #.#G..#
      #..#..#
      #...#G#
      #...G.#
      #######
    EOF

    battle = Battle.new(BATTLE_3_INITIAL)
    battle.play!
    assert_equal(35, battle.full_rounds_completed)
    assert_equal(27755, battle.outcome)
    assert_equal('G', battle.victors)
  end

  BATTLE_4_INITIAL = <<~EOF
    #######
    #.E...#
    #.#..G#
    #.###.#
    #E#G#G#
    #...#G#
    #######
  EOF

  def test_battle_4
    final = <<~EOF
      #######
      #.....#
      #.#G..#
      #.###.#
      #.#.#.#
      #G.G#G#
      #######
    EOF

    battle = Battle.new(BATTLE_4_INITIAL)
    battle.play!
    assert_equal(54, battle.full_rounds_completed)
    assert_equal(28944, battle.outcome)
    assert_equal('G', battle.victors)
  end

  BATTLE_5_INITIAL = <<~EOF
    #########
    #G......#
    #.E.#...#
    #..##..G#
    #...##..#
    #...#...#
    #.G...G.#
    #.....G.#
    #########
  EOF
  def test_battle_5
    final = <<~EOF
      #########
      #.G.....#
      #G.G#...#
      #.G##...#
      #...##..#
      #.G.#...#
      #.......#
      #.......#
      #########
    EOF

    battle = Battle.new(BATTLE_5_INITIAL)
    battle.play!
    assert_equal(20, battle.full_rounds_completed)
    assert_equal(18740, battle.outcome)
    assert_equal('G', battle.victors)
  end


  def test_reddit_1
    initial = <<~EOF
      #######
      #######
      #.E..G#
      #.#####
      #G#####
      #######
      #######
    EOF

    battle = Battle.new(initial)
    assert_equal(battle.get_location(3,2), battle.units.values.first.next_move)
  end

  def test_reddit_2
    initial = <<~EOF
      ####
      #GG#
      #.E#
      ####
    EOF

    battle = Battle.new(initial)
    (goblin1, goblin2, elf) = battle.units.values
    assert_equal(goblin2, elf.next_attack_target)
  end

  def test_reddit_3
    initial = <<~EOF
      #######
      #######
      #####G#
      #..E..#
      #G#####
      #######
      #######
    EOF
    battle = Battle.new(initial)

    elf = battle.units.values[1]
    assert_equal(battle.get_location(2, 3), elf.next_move)
  end

  def test_reddit_4
    initial = <<~EOF
      ########
      #..E..G#
      #G######
      ########
    EOF

    battle = Battle.new(initial)
    battle.tick!
    tick1 = <<~EOF
      ########
      #GE..G.#
      #.######
      ########
    EOF
    assert_equal(tick1.strip, battle.to_s)
  end

  def really_simple_decisions
    initial = <<~EOF
      ######
      #G...#
      #.E..#
      ######
    EOF
    battle = Battle.new(initial)
    (goblin, elf) = battle.units.values
    assert_equal(battle.get_location(2, 1), elf.next_target)
    assert_equal(battle.get_location(2, 1), elf.next_move)
    assert_equal(battle.get_location(2, 1), goblin.next_target)
    assert_equal(battle.get_location(2, 1), goblin.move)
  end

  def test_battle_1_find_attack_power
    # text says "first summarized example" and that's wrong. It's the one that it fully does.
    battle = Battler.find_elf_attack_power(3, FULL_BATTLE_STARTING_GRID)
    assert_equal(15, battle.default_elf_attack_power)
    assert_equal(29, battle.full_rounds_completed)
    assert_equal(4988, battle.outcome)
  end


  def test_battle_2_find_attack_power
    battle = Battler.find_elf_attack_power(3, BATTLE_2_INITIAL)
    assert_equal(4, battle.default_elf_attack_power)
    assert_equal(33, battle.full_rounds_completed)
    assert_equal(31284, battle.outcome)
  end

  def test_battle_3_find_attack_power
    battle = Battler.find_elf_attack_power(3, BATTLE_3_INITIAL)
    assert_equal(15, battle.default_elf_attack_power)
    assert_equal(37, battle.full_rounds_completed)
    assert_equal(3478, battle.outcome)
  end

  def test_battle_4_find_attack_power
    battle = Battler.find_elf_attack_power(3, BATTLE_4_INITIAL)
    assert_equal(12, battle.default_elf_attack_power)
    assert_equal(39, battle.full_rounds_completed)
    assert_equal(6474, battle.outcome)
  end

  def test_battle_5_find_attack_power
    battle = Battler.find_elf_attack_power(3, BATTLE_5_INITIAL)
    assert_equal(34, battle.default_elf_attack_power)
    assert_equal(30, battle.full_rounds_completed)
    assert_equal(1140, battle.outcome)

  end

end
