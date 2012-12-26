# Global variables
gakko = this
gakko.PI = 3.14159265358
gakko.numFrames = 6                   # Number of nav items
gakko.interval = PI/2                 # The angle interval on the nav-logo circle
gakko.extraAngle = 0                  # The preceding angle (to put gakko.interval 
                                      # in the correct (II) quadrant)
gakko.paths = gakko.expandedPaths = []# The arrays where the nav-logo shapes are stored
gakko.index = 0                       # The current window 'panel' being shown

# Utility: maps value from in between min and max 
# linearly to in between newMin and newMax
map = (val, min, max, newMin, newMax) ->
  return (newMax - newMin)*(val-min)/(max - min) + newMin

# Changes background image based on background position
backShift = () ->
  panelHeight = $(".panel").height()
  top = $("body").scrollTop()
  newIndex = Math.floor (((top-20)/panelHeight) + 1)/2 
  if newIndex isnt gakko.index
    $(".back").hide()
    back = $(".back")[newIndex]
    $(back).show()
    gakko.index = newIndex

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
    R = bound*0.6
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
  # numFrames + 1 times
  for num in [0..numFrames]
    angle = num*(interval/numFrames) + angle_extra
    big_x = R*Math.cos(angle)
    big_y = R*Math.sin(angle)
    big_point = [(bound+big_x).toFixed(3), (bound-big_y).toFixed(3)]
    big.push big_point

    y_sign = x_sign = 1
    x_sign = -1 if num is 0
    y_sign = -1 if num >= numFrames-1
    slope = (big_y) / (big_x)
    slope *= 10 if num is numFrames
    
    small_x = x_sign*Math.sqrt(-(inner_offset*inner_offset) + (r*r*slope*slope) + r*r)
    small_x = inner_offset*slope - small_x
    small_x = small_x / (slope*slope + 1)
    small_y = y_sign*Math.sqrt(r*r - small_x*small_x) + inner_offset
    small_point = [(bound+small_x).toFixed(3), (bound-small_y).toFixed(3)]
    small.push small_point

  paths = []
  # numFrames times
  for i in [0...numFrames]
    path = "M #{big[i][0]},#{big[i][1]} A #{R},#{R} 0 0,0 #{big[i+1][0]}, #{big[i+1][1]} "
    path += "L #{small[i+1][0]}, #{small[i+1][1]} "
    path += "A #{r},#{r} 0 0,1 #{small[i][0]}, #{small[i][1]} Z"
    paths.push path
  paths

# Changes the placement and size of the nav-logo captions
adjustCaptions = () ->
  radius = $("#nav-logo").width()+30            # 20 was picked as a padding
  size = map(radius, 120.0, 300.0, 10.0, 22.0)  # 120, 300 come from #nav-logo min and max-width.
  for num in [0...gakko.numFrames]
    step = gakko.interval/gakko.numFrames
    angle = (num+0.5)*step + gakko.angleExtra
    bottom = radius*Math.sin(angle).toFixed(3)
    if num is gakko.numFrames - 1
      toAdd = map(radius, 120.0, 300.0, 3, 20)
      bottom += toAdd
    right = -radius*Math.cos(angle).toFixed(3)  # Negative because we're in quadrant II but measuring positively
    $("#cap-#{num}").css(
      fontSize: "#{size}px"
      lineHeight: "#{size}px"
      # width: "#{size*4.5}px"
      bottom: "#{bottom}px"
      right: "#{right+2*(numFrames - num)}px"   # Move right-most items more than away from edge of screen
    )

setupNav = () ->
  $("#nav-logo").height($("#nav-logo").width())
  gakko.paths = makePaths()
  gakko.expandedPaths = makePaths(true)
  for p, i in gakko.pieces[0]
    d3.select(p).attr("d", gakko.paths[i])
  adjustCaptions()

$(document).ready ->
  # Setup
  gakko.pieces = d3.selectAll(".nav-piece")
  origColor = "black"
  origColor = "#513E37"
  origOpacity = 0.3
  newColor = "#B82025"
  gakko.pieces
    .attr("fill", origColor)
    .attr("fill-opacity", origOpacity)
  setupNav()                   # The rest, which is also done in window.resize
  # Fade the logo in
  setTimeout( ->
    $(".logo").toggleClass "hidden"
  , 500)
  # Window events
  $(window).scroll(() ->
    backShift()
  ).resize(() ->
    setupNav()
  )
  # Navigation animation 
  duration = 200
  $("#nav-logo").mouseenter(() ->
    $("#nav-captions").fadeIn("fast")
    for p, i in gakko.pieces[0]
      d3.select(p)
        .transition().duration(duration)
        .attr("d", gakko.expandedPaths[i])
  ).mouseleave(() ->
    $("#nav-captions").fadeOut("fast")
    for p, i in gakko.pieces[0]
      d3.select(p)
        .transition().duration(duration)
        .attr("d", gakko.paths[i])
  )

  gakko.pieces.on("mouseover", ->
    d3.select(this)
      .attr("fill", newColor)
      .attr("fill-opacity", 1)
    id = d3.select(this).attr("target")
    $("#cap-#{id}").addClass("highlight")
  ).on("mouseout", ->
    d3.select(this)
      .attr("fill", origColor)
      .attr("fill-opacity", origOpacity)
    id = d3.select(this).attr("target")
    $("#cap-#{id}").removeClass("highlight")
  )
  # Navigation click
  $(".js-nav").click( ->
    id = parseInt(d3.select(this).attr("target"))
    from = $("body").scrollTop()
    dest = $($(".panel")[id]).offset().top
    time = Math.abs(dest-from)/3 + 100
    $("body,html,document").animate(
      scrollTop: dest+10
    , time)
  )

  # About page

  $(".about-link").click(->
    if not $(this).hasClass("selected")
      $(".about-link.selected").removeClass("selected")
      $(".about-content.shown").removeClass("shown")
      target = $(this).attr("target")
      $(this).addClass("selected")
      $(".about-content.#{target}").addClass("shown")

  )
