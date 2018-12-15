class ManhattanAreas
  attr_accessor :coords
  def initialize(input_lines)
    @coords = input_lines.map {|line| line.chomp.split(/,\s*/)}
  end

  def self.from_file(file)
    ManhattanAreas.new(File.readlines(file))
  end

  def grid_size
  
  end

end
