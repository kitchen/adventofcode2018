class Marbles
  Marble = Struct.new(:value, :counter_clockwise, :clockwise)
  def self.emitter
    marble_madness = Enumerator.new do |y|
      board = [0]
      marble = 0
      current_marble = Marble.new(0)
      current_marble[:clockwise] = current_marble
      current_marble[:counter_clockwise] = current_marble
      current_marble[:value] = 0

      loop do
        # puts "board: #{board.join(" ")}"
        marble += 1
        if marble % 23 == 0
          current_marble = current_marble.counter_clockwise.counter_clockwise.counter_clockwise.counter_clockwise.counter_clockwise.counter_clockwise.counter_clockwise

          # since we're about to orphan it
          old_marble = current_marble
          # figure out the neighbers
          counter_clockwise = current_marble[:counter_clockwise]
          clockwise = current_marble[:clockwise]

          # point them at each other
          counter_clockwise[:clockwise] = clockwise
          clockwise[:counter_clockwise] = counter_clockwise

          # orphan it
          current_marble[:clockwise] = nil
          current_marble[:counter_clockwise] = nil

          # set the current_marble to the one clockwise from what we removed
          current_marble = clockwise

          # return a score
          y << marble + old_marble[:value]
        else
          new_marble = Marble.new(marble, current_marble.clockwise, current_marble.clockwise.clockwise)

          new_marble.counter_clockwise.clockwise = new_marble
          new_marble.clockwise.counter_clockwise = new_marble
          current_marble = new_marble

          y << 0
        end
      end
    end
  end

  def self.wrapped_index(board_size, current_index, shift)
    if shift + current_index >= board_size
      shift + current_index - board_size
    elsif shift + current_index < 0
      shift + current_index + board_size
    else
      current_index + shift
    end
  end

end


class MarblesPlayer
  attr_accessor :scoreboard
  attr_reader :num_players
  attr_accessor :emitter

  def initialize(num_players)
    @scoreboard = Hash.new {|h, k| h[k] = 0}
    @num_players = num_players
    @emitter = Marbles.emitter
  end

  # play the game until a ball is returned with the stop_score
  def play(iterations)
    last_score = 0
    current_player = 0
    iterations.times do
      current_player += 1
      current_player = 1 if current_player > num_players
      scoreboard[current_player] += emitter.next
    end
    scoreboard
  end
end
