require './lumber'
require 'set'


filename = ARGV[0] || 'input.txt'
lumber = Lumber.new(File.readlines(filename))

digests = Set.new
digests << lumber.md5

until lumber.minute == 10
  lumber.tick!
  digest = lumber.md5
  if digests.include?(digest)
    puts "found duplicate digest at #{lumber.minute}: #{digest}"
  end
  digests << digest
end

puts "resource value after 10 minutes: #{lumber.resource_value}"


first_dupe = nil
first_dupe_index = nil
second_dupe_index = nil
dupe_cycle = []
until lumber.minute == 1_000_000_000
  lumber.tick!
  digest = lumber.md5
  puts "#{lumber.minute} -> #{lumber.resource_value} -> #{digest}"
  if !first_dupe && digests.include?(digest)
    puts "first dupe found at #{lumber.minute} -> #{digest}"
    first_dupe = digest
    first_dupe_index = lumber.minute
    dupe_cycle << lumber.resource_value
  elsif first_dupe == digest
    puts "dupe repeat at #{lumber.minute} -> #{digest}"
    second_dupe_index = lumber.minute
    break
  elsif first_dupe
    dupe_cycle << lumber.resource_value
  elsif !first_dupe
    digests << digest
  end
end

DESIRED = 1_000_000_000
resource_value_at_desired =  dupe_cycle[(DESIRED - first_dupe_index) % (second_dupe_index - first_dupe_index)]
puts "resource value after #{DESIRED} minutes: #{resource_value_at_desired}"
# puts "resource value after 1000000000 minutes: #{lumber.resource_value}"


require 'pry'
binding.pry

1
