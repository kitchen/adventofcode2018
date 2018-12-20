class Cooker
  Recipe = Struct.new(:score, :left, :right)
  Elf = Struct.new(:current_recipe)

  ELF_TEMPLATES = %W{
    "%(score)"
    '%(score)'
    [%(score)]
    {%(score)}
  }
  def self.generator(starting_scoreboard, number_of_elves = 2)
    score0 = Recipe.new(starting_scoreboard.shift)
    scoreboard = [score0]
    starting_scoreboard.each do |score|
      add_to_scoreboard(scoreboard, score)
    end

    elves = number_of_elves.times.map {|i| Elf.new(scoreboard[i])}
    Enumerator.new do |y|
      new_score = elves.sum {|elf| elf.current_recipe.score}
      loop do
        new_score.digits.reverse.each do |digit|
          add_to_scoreboard(scoreboard, digit)
          y << digit
        end

        new_score.times do
          elves.each do |elf|
            elf.current_recipe = elf.current_recipe.right
          end
        end
      end
    end
  end

  def self.add_to_scoreboard(scoreboard, score)
    first = scoreboard.first
    last = scoreboard.last
    new_score = Recipe.new(score, last, first)
    last.right = new_score
    first.left = new_score
    scoreboard << new_score
  end

  def self.draw_scoreboard
    
  end
end
