# Some useful global variables
gakko = this
gakko.PI = 3.14159265358
gakko.numFrames = 6                   # Number of nav items
gakko.interval = PI/2                 # The angle interval on the nav-logo circle
gakko.extraAngle = 0                  # The preceding angle (to put interval 
                                      # in the correct (II) quadrant)
gakko.paths = gakko.expandedPaths = []# The arrays where the nav-logo shapes are stored

# Utility: maps value from in between min and max 
# linearly to in between newMin and newMax
map = (val, min, max, newMin, newMax) ->
  return (newMax - newMin)*(val-min)/(max - min) + newMin

# Changes background image based on background position
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
# Makes the nav logo shapes, for both expanded and contracted
makePaths = (expand=false) ->
  # BOUND_SCALE is necessary because the circles aren't centered 
  # on the bottom right corner (this helps adjust the width of the svg)
  BOUND_SCALE = 0.927     
  bound = $("#nav-logo").width() * BOUND_SCALE
  center_offset = $("#nav-logo").width() * (1.05-BOUND_SCALE)
  numFrames = gakko.numFrames
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
  angle_difference = gakko.PI/2 - angle_extra
  interval = gakko.PI/2 + 2*angle_difference

  gakko.angleExtra = angle_extra
  gakko.interval = interval

  big = []
  small = []
  for num in [0..numFrames]
    angle = num*(interval/numFrames) + angle_extra
    big_x = R*Math.cos(angle)
    big_y = R*Math.sin(angle)
    big_point = [(bound+big_x).toFixed(3), (bound-big_y).toFixed(3)]
    big.push big_point

    y_sign = x_sign = 1
    x_sign = -1 if num is 0
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
  for i in [0...numFrames]
    path = "M #{big[i][0]},#{big[i][1]} A #{R},#{R} 0 0,0 #{big[i+1][0]}, #{big[i+1][1]} "
    path += "L #{small[i+1][0]}, #{small[i+1][1]} "
    path += "A #{r},#{r} 0 0,1 #{small[i][0]}, #{small[i][1]} Z"
    paths.push path
  paths

# Changes the placement and size of the nav-logo captions
adjustCaptions = () ->
  radius = $("#nav-logo").width()+20            # 20 was picked as a padding
  size = map(radius, 120.0, 300.0, 10.0, 24.0)  # 120, 300 come from #nav-logo min and max-width.
  for num in [1..gakko.numFrames]
    step = gakko.interval/gakko.numFrames
    angle = (num-0.5)*step + gakko.angleExtra
    bottom = radius*Math.sin(angle).toFixed(3)
    if num is gakko.numFrames
      toAdd = map(radius, 120.0, 300.0, 3, 20)
      bottom += toAdd
    right = -radius*Math.cos(angle).toFixed(3)  # Negative because we're in quadrant II but measuring positively
    $("#cap-#{num}").css(
      fontSize: "#{size}px"
      bottom: "#{bottom}px"
      right: "#{right}px"
    )

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
    3: "apply2000.jpg"
  }
  # Current index (in bImages array)
  index = 0
  $(window).scroll(() ->
    index = backShift(bImages, index)
  ).resize(() =>
    $("#nav-logo").height($("#nav-logo").width())
    gakko.paths = makePaths()
    gakko.expandedPaths = makePaths(true)
    for p, i in pieces[0]
      d3.select(p).attr("d", gakko.paths[i])
    adjustCaptions()
  )

  pieces = d3.selectAll(".nav-piece")
  newColor = "#B82025"
  origColor = pieces.attr("fill")
  $(window).resize()                  # Trigger resize event to create paths

  delay = 30
  duration = 200
  $("#nav-logo").mouseenter(() ->
    $("#nav-captions").fadeIn("fast")
    for p, i in pieces[0]
      d3.select(p)
        .transition().delay(delay*i).duration(duration)
        .attr("d", gakko.expandedPaths[i])
  ).mouseleave(() ->
    $("#nav-captions").fadeOut("fast")
    for p, i in pieces[0]
      d3.select(p)
        .transition().delay(delay*i).duration(duration)
        .attr("d", gakko.paths[i])
  )

  pieces.on("mouseover", () ->
    d3.select(this).attr("fill", newColor).attr("fill-opacity", 1)
    id = d3.select(this).attr("target")
    $("#cap-#{id}").addClass("highlight")
  ).on("mouseout", () ->
    d3.select(this).attr("fill", origColor).attr("fill-opacity", 0.5)
    id = d3.select(this).attr("target")
    $("#cap-#{id}").removeClass("highlight")
  ).on("click", () ->
    id = parseInt(d3.select(this).attr("target"))
    from = $("body").scrollTop()
    dest = $($(".panel")[id]).offset().top
    console.log from, dest
    $("body,html,document").animate(
      scrollTop: dest
    , Math.abs(dest-from)/3 + 100)
  )
