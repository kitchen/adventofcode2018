require './constants'

line_pattern = %r{
  position=<\s*
  (?<xpos>.+?) # x position
  ,\s*
  (?<ypos>.+?) # y position
  >\s*velocity=<\s*
  (?<xvelocity>.+?) # x velocity
  ,\s*
  (?<yvelocity>.+?) # y velocity
  >
}x


puts %(<html>)
puts %(<svg viewbox="#{VIEWPORT}" style="height: 100%">)
ARGF.readlines.each_with_index do |line, index|
  matches = line.match(line_pattern)
  id = %(circle_#{index})

  xpos = matches[:xpos].to_i
  ypos = matches[:ypos].to_i
  xv = matches[:xvelocity].to_i
  yv = matches[:yvelocity].to_i



  puts %(<circle cx="#{xpos + xv * INITIAL}" cy="#{ypos + yv * INITIAL}" r="1" id="#{id}" />)
  puts %(<animate xlink:href="##{id}" attributeName="cx" by="#{xv * FINAL}" dur="5s" repeatCount="0" fill="freeze" />)
  puts %(<animate xlink:href="##{id}" attributeName="cy" by="#{yv * FINAL}" dur="5s" repeatCount="0" fill="freeze" />)
end

puts %(</svg>)
puts %(</html>)
