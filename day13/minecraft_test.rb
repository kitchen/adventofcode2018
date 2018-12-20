require 'minitest/autorun'
require 'minitest/assertions'

require './minecraft'

module MinecraftTestHelpers
  def assert_crashes_at(mess, x, y)
    begin
      loop do
        mess.tick!
      end
    rescue Mess::CartCrash
      assert_equal([x,y], mess.crashed_at)
    end
  end
end

class MinecraftTest < Minitest::Test

  def setup
    @mess = Mess.new
  end

  def test_single_loop
    @mess.parse_map(File.readlines('single_loop.map'))
    assert_equal('-', @mess.tracks[1][0].char)
  end

  def test_double_loop
    @mess.parse_map(File.readlines('double_loop.map'))
    assert_equal('/', @mess.tracks[3][2].char)
    assert(true, "it didn't fail")
  end

  # because my code will crash if | doesn't have a north track ;-)
  STRAIGHT_LINE_WITH_CRASH = <<~EOF
    /
    v
    |
    |
    |
    ^
    |
  EOF

  def test_straight_line
    @mess.parse_map(STRAIGHT_LINE_WITH_CRASH.split(/\n/))
    assert_equal(:south, @mess.tracks[0][1].cart.orientation)
  end

  def test_east_west_movement
    @mess.parse_map(%w{/--->---  /---<---})

    top_cart_track = @mess.tracks[4][0]
    top_cart = top_cart_track.cart
    refute_nil(top_cart)
    assert_equal(top_cart_track, top_cart.track)
    assert_equal(:east, top_cart.orientation)

    bottom_cart_track = @mess.tracks[4][1]
    bottom_cart = bottom_cart_track.cart
    refute_nil(bottom_cart)
    assert_equal(bottom_cart_track, bottom_cart.track)
    assert_equal(:west, bottom_cart.orientation)

    @mess.tick!

    assert_equal(@mess.tracks[5][0], top_cart.track)
    assert_nil(@mess.tracks[4][0].cart)
    assert_equal(@mess.tracks[3][1], bottom_cart.track)
    assert_nil(@mess.tracks[4][1].cart)
  end


  def test_simple_crash
    @mess.parse_map(%w{/--->---<---})
    @mess.tick!
    assert_raises(Mess::CartCrash) do
      @mess.tick!
    end
    assert_equal([6,0], @mess.crashed_at)
  end

  def test_rounds_a_corner
    @mess.parse_map(%w{
      /--
      |
      ^
    })

    cart = @mess.carts.values.first
    @mess.tick!
    assert_equal(cart, @mess.tracks[0][1].cart)
    @mess.tick!
    assert_equal(cart, @mess.tracks[0][0].cart)
    assert_equal(:east, cart.orientation)
    @mess.tick!
    assert_equal(cart, @mess.tracks[1][0].cart)
    assert_equal(:east, cart.orientation)
  end

  def test_rounds_another_corner
    @mess.parse_map(%w{
      /-<---
      |
    })

    cart = @mess.carts.values.first
    @mess.tick!
    @mess.tick!
    @mess.tick!
    assert_equal(cart, @mess.tracks[0][1].cart)
    assert_equal(:south, cart.orientation)
  end

  def test_makes_a_clockwise_lap
    @mess.parse_map(File.readlines('clockwise.map'))
    cart = @mess.carts.values.first
    beginning_track = cart.track
    8.times { @mess.tick! }
    assert_equal(beginning_track, cart.track)
  end

  def test_makes_a_counter_clockwise_lap
    @mess.parse_map(File.readlines('counter_clockwise.map'))
    cart = @mess.carts.values.first
    beginning_track = cart.track
    8.times { @mess.tick! }
    assert_equal(beginning_track, cart.track)
  end

  def test_multiple_carts_on_a_loop
    @mess.parse_map(File.readlines('clockwise_many_carts.map'))
    starting_tracks = @mess.carts.values.map {|cart| [cart, cart.track]}.to_h
    8.times { @mess.tick! }

    starting_tracks.each do |cart, track|
      assert_equal(track, cart.track)
    end
  end

  def test_navigates_intersection_basic
    @mess.parse_map(File.readlines('intersection_test.map'))
    cart = @mess.carts.values.first
    5.times { @mess.tick! }
    assert_equal(@mess.tracks[6][0], cart.track)
  end

  def test_triple_loop_with_carts
    @mess.parse_map(File.readlines('triple_loop_with_carts.map'))
  end

  def test_annihilate
    @mess.parse_map(File.readlines('annihilate.map'))
    @mess.annihilate = true
    loop do
      @mess.tick!
      break if @mess.carts.count <= 1
    end
    last_cart_standing = @mess.carts.values.first
    assert_equal([6,4], [last_cart_standing.track.x, last_cart_standing.track.y])
  end

end
