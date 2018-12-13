class SimilarBoxIds
  def self.checksum(ids)
    twos = 0
    threes = 0
    
    ids.each do |id|
      char_counts = Hash[id.chars.group_by {|x| x}.map {|k,v| [k,v.count]}]
      twos += 1 if (char_counts.select {|k, v| v == 2}).count > 0
      threes += 1 if (char_counts.select {|k, v| v == 3}).count > 0
    end
    twos * threes
  end

  def self.common_chars(a, b)
    stuff = []
    a.chars.each_with_index do |char ,i|
      stuff << char if a.chars[i] == b.chars[i]
    end
    stuff.join("")
  end

  def self.make_pairs(ids)
    pairs = []
    ids = ids.dup

    while ids.count > 0
      a = ids.shift
      ids.each do |b|
        pairs << [a,b]
      end
    end

    pairs
  end

  def self.find_diff_by(ids, diff_by)
    pairs = make_pairs(ids)

    pairs.select do |(a,b)|
      (a.length - common_chars(a, b).length) == diff_by
    end
  end


  def self.ids_from_file(file)
    File.readlines(file).map do |line|
      line.chomp
    end
  end
end


if __FILE__ == $0
  require 'pry'
  binding.pry
end
