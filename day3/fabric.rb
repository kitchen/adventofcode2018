require 'set'

class Fabric
  attr_accessor :claims

  def initialize(claim_descs)
    @claims = claim_descs.map do |claim_line|
      Claim.new(claim_line)
    end
  end

  def self.from_file(claims_file)
    Fabric.new(File.readlines(claims_file))
  end

  def overlaps
    seen = Set.new
    coords = Set.new
    claims.each do |claim|
      coords.merge(seen & claim.to_coordinate_map.to_set)
      seen.merge(claim.to_coordinate_map.to_set)
    end
    coords
  end

  def find_solo_claim
    claims.each do |claim|
      puts "#{claim.id}"
      local_claims = claims.dup
      local_claims.delete(claim)
      subset = local_claims.each_with_object(Set.new) {|local_claim, obj| obj.merge(local_claim.to_coordinate_map) }
      return claim if (claim.to_coordinate_map.to_set & subset).empty?
    end
  end
end

class Claim
  attr_accessor :id, :top_margin, :left_margin, :width, :height

  def initialize(desc)
    (_, id, left_margin, top_margin, width, height) = desc.match(/^#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/).to_a
    @id = id
    @top_margin = top_margin.to_i
    @left_margin = left_margin.to_i
    @width = width.to_i
    @height = height.to_i
  end

  def to_coordinate_map
    return @coords if @coords
    @coords = []
    (left_margin...(left_margin + width)).each do |x|
      (top_margin...(top_margin + height)).each do |y|
        @coords << [x,y]
      end
    end

    @coords
  end

  def overlap(claim)
    self.to_coordinate_map & claim.to_coordinate_map
  end

  def overlaps_with?(claim)
    !overlap(claim).empty?
  end
end


if __FILE__ == $0
  require 'pry'
  binding.pry
end
