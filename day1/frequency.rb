
frequency = 0

ARGF.readlines.each do |line|
  frequency += line.to_i
end

puts frequency

