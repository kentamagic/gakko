backShift = (bImages, currIndex) ->
  panelHeight = $(".panel").height()
  top = $("body").scrollTop()
  newIndex = Math.floor (((top-20)/panelHeight) + 1)/2 
  if newIndex isnt currIndex
    newImg = bImages[newIndex]
    # console.log newImg, "t, h, ni: ", top, panelHeight, newIndex
    if newImg
      $("body").css("backgroundImage", "url(/images/backgrounds/#{newImg})");
      return newIndex

# old: M 150, 50 a 100,100 0 1,1 -0.1,0 M 150 75 a 60, 60 0 1,1 -0.1 0
# new: M 150, 0 a 150,150 0 1,1 -0.1,0 M 150 25 a 100, 100 0 1,1 -0.1 0

makePaths = (expand=false) ->
  PI = 3.14159265358
  center_offset = 44
  center_offset_y = 84 # Unused
  bound = $("#nav-logo").width() - center_offset/2
  console.log bound
  num_frames = 6      # => we need num_frames+1 values in each array
  if expand
    R = bound
  else
    R = bound*0.821
  r = R*0.65
  inner_offset = R*0.18

  # Big circle equation:    x^2 + y^2 = R^2
  # Little circle equation: x^2 + (y-inner_offset)^2 = r^2
  # To convert from actaul coordinates to svg coordinates:
  # (svg_x, svg_y) = (x+bound, bound-y)

  start_y = Math.sqrt(R*R - (center_offset*center_offset))
  angle_extra = Math.atan(start_y/center_offset)
  angle_difference = PI/2 - angle_extra
  interval = PI/2+2*angle_difference

  big = []
  small = []
  for num in [0..num_frames]
    angle = num*(interval/num_frames) + angle_extra
    big_x = R*Math.cos(angle)
    big_y = R*Math.sin(angle)
    big_point = [(bound+big_x).toFixed(3), (bound-big_y).toFixed(3)]
    big.push big_point

    y_sign = x_sign = 1
    x_sign = -1 if angle < PI/2
    y_sign = -1 if num >= 5
    slope = (big_y) / (big_x)
    slope *= 10 if num is 6
    
    small_x = x_sign*Math.sqrt(-(inner_offset*inner_offset) + (r*r*slope*slope) + r*r)
    small_x = inner_offset*slope - small_x
    small_x = small_x / (slope*slope + 1)
    small_y = y_sign*Math.sqrt(r*r - small_x*small_x) + inner_offset
    small_point = [(bound+small_x).toFixed(3), (bound-small_y).toFixed(3)]
    small.push small_point

  paths = []
  for i in [0...num_frames]
    path = "M #{big[i][0]},#{big[i][1]} A #{R},#{R} 0 0,0 #{big[i+1][0]}, #{big[i+1][1]} "
    path += "L #{small[i+1][0]}, #{small[i+1][1]} "
    path += "A #{r},#{r} 0 0,1 #{small[i][0]}, #{small[i][1]} Z"
    paths.push path
  paths

$(document).ready ->
  # Fade the logo in
  setTimeout( ->
    $(".logo").toggleClass "transparent"
  , 500)

  # Array of all background images
  bImages = {
    0: "background2000.jpg"
    1: "about2000.jpg"
    2: "connect_small.jpg"
  }
  index = 0
  # Switch them in and out depending
  $(window).bind('mousewheel', () ->
    index = backShift(bImages, index)
  )

  pieces = d3.selectAll(".nav-piece")
  newColor = "#B82025"
  origColor = pieces.attr("fill")
  paths = makePaths()

  for p, i in pieces[0]
    d3.select(p).attr("d", paths[i])

  pieces.on("mouseover", () ->
    d3.select(this).transition().attr("fill", newColor).attr("fill-opacity", 1)
    id = d3.select(this).attr("target")
    $("#cap-#{id}").addClass("shown")
    # console.log id
  ).on("mouseout", () ->
    d3.select(this).transition().attr("fill", origColor).attr("fill-opacity", 0.5)
    id = d3.select(this).attr("target")
    $("#cap-#{id}").removeClass("shown")
  )

  $("#anav-logo").mouseenter(() ->
    nav
      .transition()
      .attr("d", newPath)
      .attr("fill", newColor)
  ).mouseleave(() ->
    nav
      .transition()
      .attr("d", origPath)
      .attr("fill", origColor)
  )

  $("#nav-hide").click(() ->
    $("#nav-help").hide()
  )
