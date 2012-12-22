# Remember, svg values are HALF a pixel!!
PI = 3.14159265358
bound = 250
center_offset = 44
num_frames = 6      # => we need num_frames+1 values in each array

R = 220
r = 144
inner_offset = 40
ex_R = 280
ex_r = 182
ex_inner_offset = 50

# Big circle equation:    x^2 + y^2 = R^2
# Little circle equation: x^2 + (y-inner_offset)^2 = r^2
# To convert from actaul coordinates to svg coordinates:
# (svg_x, svg_y) = (x+bound, bound-y)

start_y = Math.sqrt(R*R - (center_offset*center_offset))
angle_extra = Math.atan(start_y/center_offset)
angle_difference = PI/2 - angle_extra
interval = PI/2+2*angle_difference           # 2 for at the beginning and at end

big = []
small = []
(0..num_frames).each do |num|
  angle = num*(interval/num_frames) + angle_extra

  big_x = R*Math.cos(angle)
  big_y = R*Math.sin(angle)
  big_point = [(bound+big_x).round(3), (bound-big_y).round(3)]
  big << big_point

  y_sign = x_sign = 1
  x_sign = -1 if angle < PI/2
  y_sign = -1 if angle > PI

  slope = (big_y) / (big_x)
  # puts "big point: "+big_x.to_s+", "+big_y.to_s+" slope: "+slope.to_s
  small_x = x_sign*Math.sqrt(-(inner_offset*inner_offset) + (r*r*slope*slope) + r*r)
  small_x = inner_offset*slope - small_x
  small_x = small_x / (slope*slope + 1)
  small_y = y_sign*Math.sqrt(r*r - small_x*small_x) + inner_offset
  small_point = [(bound+small_x).round(3), (bound-small_y).round(3)]

  small << small_point
  # puts "big: "+big_point.to_s+" small: "+small_point.to_s
  # system: y = slope * x => x^2 + (slope*x-inner_offset)^2 = r^2
  # => x = (inner_offset*slope - Math.sqrt(-inner_offset*inner_offset + (r*r*slope*slope) + r*r))
  #    x = x/(slope*slope + 1)
end
# p big
# p small

string = ""
(0...num_frames).each do |i|
  path = "M #{big[i][0]},#{big[i][1]} A #{R},#{R} 0 0,0 #{big[i+1][0]}, #{big[i+1][1]} "
  path += "L #{small[i+1][0]}, #{small[i+1][1]} "
  path += "A #{r},#{r} 0 0,1 #{small[i][0]}, #{small[i][1]} Z"

  string += "<path class='nav-piece' target='#{i+1}' fill='#513E37'"
  string += " fill-opacity='0.5' stroke='none' />\n\t\t\t"
end

puts string



=begin
small = [
  [330, 128],
  [254.873, 131.587],
  [215.202, 153.127],
  [185.287, 185.286],
  [167.482, 223.4905],
  [163.004, 263.0243],
  [180, 330]
]
small << [330, 128]
big_test = []

(1..5).each do |num|
  t = num*PI/12.0
  y = (Math.cos(t)*R).round(3)
  x = -Math.sqrt(R*R - y*y).round(3)

  s_y = (Math.cos(t)*r + y_o).round(3)
  s_x = -Math.sqrt(r*r - (s_y - y_o)*(s_y - y_o)).round(3)
  big_test << [x, y]
  big << [x+o, o-y]
  # small << [s_x+o, o-s_y]
  # puts "(#{x+o}, #{o-y}), (#{s_x+o}, #{o-s_y})"
end

big << [89, 330]
# small << [180, 330]
# p big
# p small

# M 150, 50 a 100,100 0 1,1 -0.1,0 M 150 75 a 60, 60 0 1,1 -0.1 0
numbers = %w(one two three four five six)
string = ""
(0..5).each do |i|
  path = "M #{big[i][0]}, #{big[i][1]} A #{R},#{R} 0 0,0 #{big[i+1][0]}, #{big[i+1][1]} "
  path += "L #{small[i+1][0]}, #{small[i+1][1]} "
  path += "A #{r},#{r} 0 0,1 #{small[i][0]}, #{small[i][1]} Z"
  string += "<path class='nav-piece' target='#{i+1}' fill='#513E37'"
  string += " fill-opacity='0.5' stroke='none' d='#{path}' />\n\t\t"
end

puts string
=end