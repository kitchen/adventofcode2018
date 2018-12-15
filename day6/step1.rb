require './manhattan_areas'

areas = ManhattanAreas.from_file('input.txt')

puts "biggest area is #{areas.finite_areas.values.map(&:size).sort.last}"
