class Marbles
  def self.emitter
    marble_madness = Enumerator.new do |y|
      board = [0]
      marble = 0
      current_marble = 0
      current_index = 0

      loop do
        # puts "board: #{board.join(" ")}"
        marble += 1
        if marble % 23 == 0
          delete_index = wrapped_index(board.size, current_index, -7)
          score = board[delete_index] + marble
          board.delete_at(delete_index)
          current_marble = board[delete_index]
          current_index = delete_index
          y << score
        else
          insert_index = wrapped_index(board.size, current_index, 2)
          board.insert(insert_index, marble)
          current_marble = marble
          current_index = insert_index
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
