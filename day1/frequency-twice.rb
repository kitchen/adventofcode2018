frequency = 0
seen_frequencies = Hash.new(0)
found = false

# the first time through this I didn't notice the "you may have to loop through multiple times" bit :)
while !found do
  File.open(ARGV[0]).readlines.each do |line|
    before_frequency = frequency
    frequency += line.to_i

    seen_frequencies[frequency] += 1
    if seen_frequencies[frequency] == 2
      found = true
      break
    end
  end
end

puts frequency

