require 'set'
require 'term/ansicolor'

class Mess
  include Term::ANSIColor
  class MessException < Exception; end
  class CartCrash < MessException; end
  Track = Struct.new(:north, :south, :east, :west, :intersection, :cart, :x, :y, :char)
  Cart = Struct.new(:track, :orientation, :next_turn, :number)

  attr_accessor :carts
  attr_accessor :tracks
  attr_accessor :crashed_at
  attr_accessor :annihilate
  attr_accessor :annihilated

  attr_accessor :map_tiles

  attr_accessor :all_tracks

  def initialize
    @carts = {}
    @tracks = Hash.new {|h,k| h[k] = {} }
    @crashed_at = nil
    @annihilate = false
    @annihilated = {}
    @all_tracks = Set.new
  end

  CART_CHARS = %w{< > v ^}
  TRACK_CHARS = %q[\ / | - +]
  ORIENTATIONS = {'<' => :west, '>' => :east, '^' => :north, 'v' => :south}

  def parse_map(map_lines)
    cart_number = 1
    # only worry about current and things above or to the left
    map_lines.each_with_index do |line, y|
      line.chomp.chars.each_with_index do |char, x|
        cart = nil
        if CART_CHARS.include?(char)
          cart = Cart.new(nil, ORIENTATIONS[char], %i{left straight right}, cart_number)
          cart_number += 1
          char = '|' if char =~ /[v^]/
          char = '-' if char =~ /[<>]/
        end

        unless char == ' '
          if !TRACK_CHARS.include?(char)
            raise "unknown input character: #{char} at #{x}, #{y}"
          end
          # process track
          # note: I don't know if it's a rule, but it doesn't look like there are carts at any intersections
          # or corners so we can just trust the stuff we find
          track = nil
          west = tracks[x - 1][y]
          north = tracks[x][y - 1]

          case char
          when '-'
            track = Track.new(nil, nil, nil, west, false, cart, x, y, char)
            west.east = track
          when '|'
            track = Track.new(north, nil, nil, nil, false, cart, x, y, char)
            north.south = track
          when '/'
            if west && (west.char == '-' || west.char == '+')
              track = Track.new(north, nil, west, nil, false, cart, x, y, char)
              west.east = track
              north.south = track
            else
              track = Track.new(nil, nil, nil, nil, false, cart, x, y, char)
            end
          when '\\'
            if west && (west.char == '-' || west.char == '+')
              track = Track.new(nil, nil, west, nil, false, cart, x, y, char)
              west.east = track
            else
              track = Track.new(north, nil, nil, nil, false, cart, x, y, char)
              north.south = track
            end
          when '+'
            track = Track.new(north, nil, west, nil, true, cart, x, y, char)
          end

          tracks[x][y] = track
          all_tracks << track
          if cart
            cart.track = track
            @carts[cart.number] = cart
          end
        end
      end
    end

    max_x = tracks.keys.max
    max_y = tracks.values.map(&:keys).flatten.max

    @map_tiles = (0..max_y).map do |y|
      (0..max_x).map do |x|
        track = tracks[x][y]
        char = ' '
        if track
          char = track
        end
      end
    end
  end

  def tick!
    @carts.values.sort_by {|a, b| [a.track.x, a.track.y]}.each do |cart|
      unless @annihilated.keys.include?(cart.number)
        tick_cart!(cart)
      end
    end
  end

  TURNS = {
    north: { left: :west, straight: :north, right: :east },
    south: { left: :east, straight: :south, right: :west },
    west: { left: :south, straight: :west, right: :north },
    east: { left: :north, straight: :east, right: :south }
  }

  def tick_cart!(cart)
    old_track = cart.track
    x = old_track.x
    y = old_track.y

    case cart.orientation
    when :north
      y -= 1
    when :south
      y += 1
    when :west
      x -= 1
    when :east
      x += 1
    end

    # second, check for crash
    new_track = tracks[x][y]
    if new_track.cart
      if annihilate
        other_cart = new_track.cart
        new_track.cart = nil
        old_track.cart = nil
        @carts.delete(cart.number)
        @carts.delete(other_cart.number)
        @annihilated[cart.number] = cart
        @annihilated[other_cart.number] = cart

        # why is this not exiting the function?
        return
      else
        self.crashed_at = [x,y]
        raise CartCrash.new("crash at #{x}, #{y}")
      end
    end

    cart.track = new_track
    new_track.cart = cart
    old_track.cart = nil

    # fourth, check if we need to turn. different rules for corners or intersections
    case new_track.char
    when '/'
      cart.orientation = { north: :east, south: :west, east: :north, west: :south }[cart.orientation]
    when '\\'
      cart.orientation = { north: :west, south: :east, east: :south, west: :north }[cart.orientation]
    when '+'
      cart.orientation = TURNS[cart.orientation][cart.next_turn.first]
      cart.next_turn.rotate!

    end
  end


  def to_s
    @map_tiles.map.with_index do |map_row, y|
      map_row.map.with_index do |map_point, x|
        if map_point.kind_of?(Track)
          char = bright_yellow map_point.char
          if map_point.cart
            char = bright_white(on_green({north: '^', south: 'v', east: '>', west: '<'}[map_point.cart.orientation]))
            if annihilated[map_point.cart.number]
              raise "we have an annihilated cart at #{map_point.x}, #{map_point.y}"
            end
          end
          char
        else
          ' '
        end
      end.join('')
    end.join('\n')
  end

end
