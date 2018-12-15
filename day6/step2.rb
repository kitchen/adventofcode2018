require './manhattan_areas'

areas = ManhattanAreas.from_file('input.txt')

puts "safe area size is #{areas.safe_points(10000).size}"
