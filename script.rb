R = 213
r = 138
PI = 3.14159265358
o = 300
y_o = 38

big = []
big << [330, 89]
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
