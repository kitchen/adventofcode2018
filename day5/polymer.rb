
class PolymerThing
  monster_array = []
  monster_problem_array = []

  ('a'..'z').each do |a|
    monster_array << %r(#{a.upcase}#{a})
    monster_array << %r(#{a}#{a.upcase})
    monster_problem_array << %r(#{a}([^#{a}#{a.upcase}])#{a.upcase})
    monster_problem_array << %r(#{a.upcase}([^#{a}#{a.upcase}])#{a})
  end

  MONSTER = Regexp.union(monster_array)
  MONSTER_PROBLEM = Regexp.union(monster_problem_array)

  def self.react_fully(polymer)
    while can_react?(polymer)
      polymer = react_step(polymer)
    end

    polymer
  end

  def self.can_react?(polymer)
    MONSTER.match(polymer)
  end

  def self.react_step(polymer)
    polymer.gsub(MONSTER, '')
  end


  def self.react_fully_with_deletions(polymer)
  end

  def self.find_problematic_units(polymer)
  end
end

