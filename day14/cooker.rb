class Cooker
  Recipe = Struct.new(:score, :left, :right)
  Elf = Struct.new(:current_recipe)

  ELF_TEMPLATES = %W{
    (%s)
    [%s]
    "%s"
    '%s'
    {%s}
  }
  def self.generator(starting_scoreboard, number_of_elves = 2)
    score0 = Recipe.new(starting_scoreboard.shift)
    scoreboard = [score0]
    starting_scoreboard.each do |score|
      add_to_scoreboard(scoreboard, score)
    end

    elves = number_of_elves.times.map {|i| Elf.new(scoreboard[i])}
    # puts render_scoreboard(scoreboard, elves)

    Enumerator.new do |y|
      loop do
        new_score = elves.sum {|elf| elf.current_recipe.score}
        new_score.digits.reverse.each do |digit|
          add_to_scoreboard(scoreboard, digit)
          y << digit
        end

        # puts "ran out of digits, elves need to move and work more!"
        # puts render_scoreboard(scoreboard, elves)

        elves.each do |elf|
          # puts "elf is moving #{elf.current_recipe.score + 1} times"
          (elf.current_recipe.score + 1).times do
            elf.current_recipe = elf.current_recipe.right
          end
        end
        # puts "elves have moved!"
        # puts render_scoreboard(scoreboard, elves)

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

  def self.render_scoreboard(scoreboard, elves)
    scoreboard.map do |recipe|
      elf = elves.find {|elf| elf.current_recipe == recipe}
      if elf
        template = ELF_TEMPLATES[elves.index(elf)]
      else
        template = ' %s '
      end
      template % (recipe.score)
    end.join('')
  end
  
  def self.next_ten(start, elves, from)
    self.generator(start, elves).take(from + 10 - start.size - 1).slice(-10, 10).map(&:to_s).join('')
  end
  
  def self.first_appears(pattern)
    pattern = pattern.chars.map(&:to_i)
    pattern_size = pattern.size
    scoreboard = [3,7]
    sequence_generator = generator(scoreboard)
    recipes = 2

    until pattern == scoreboard
      scoreboard << sequence_generator.next
      recipes += 1
      if scoreboard.size > pattern_size
        scoreboard.shift
      end
    end
    
    recipes - pattern_size
  end
end
