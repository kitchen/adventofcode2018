require 'ostruct'

class Marbles
  def self.emitter
    marble_madness = Enumerator.new do |y|
      board = [0]
      marble = 0
      current_marble = OpenStruct.new
      current_marble.clockwise = current_marble
      current_marble.counter_clockwise = current_marble
      current_marble.value = 0

      loop do
        # puts "board: #{board.join(" ")}"
        marble += 1
        if marble % 23 == 0
          7.times do
            current_marble = current_marble.counter_clockwise
          end
          counter_clockwise = current_marble.counter_clockwise
          clockwise = current_marble.clockwise

          counter_clockwise.clockwise = clockwise
          clockwise.counter_clockwise = counter_clockwise

          y << marble + current_marble.value
        else
          one_marble = current_marble.clockwise
          two_marble = one_marble.clockwise

          current_marble = OpenStruct.new
          current_marble.counter_clockwise = one_marble
          one_marble.clockwise = current_marble
          current_marble.clockwise = two_marble
          two_marble.counter_clockwise = current_marble
          current_marble.value = marble
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
