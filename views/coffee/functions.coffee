# Define Gakko
window.Gakko = Gakko = {
  # Constants
  PI: 3.14159265358
  numFrames: 6                    # Number of nav items
  interval: @PI/2                 # The angle interval on the nav-logo circle
  extraAngle: 0

  # Variables
  paths: []                       # The arrays where the nav-logo shapes/outlines are stored
  expandedPaths: []
  outlines: []
  expandedOutlines: []            # The current window 'panel' being shown
  backIndex: 0

  # Functions

  # Utility: maps value from in between min and max 
  # linearly to in between newMin and newMax
  map: (val, min, max, newMin, newMax) ->
    return (newMax - newMin)*(val-min)/(max - min) + newMin

  # Changes background image based on background position
  backShift: ->
    panelHeight = $(".panel").height()
    top = $("body").scrollTop()
    num = Math.floor (((top-20)/panelHeight) + 1)
    if num <= 2
      newIndex = Math.floor num/2 
    else
      newIndex = Math.floor (num+1)/2
    if newIndex isnt @backIndex
      $(".back").hide()
      back = $(".back")[newIndex]
      $(back).show()
      @backIndex = newIndex

  navColorShift: ->
    panelHeight = $(".panel").height()
    bottom = $("body").scrollTop() + $(window).height()
    num = Math.floor(bottom/panelHeight)
    if num%2 is 0
      @origColor = "white"
      @origOpacity = 0.7
      $(".nav-caption").removeClass("dark")
      console.log $(".nav-caption")
    else
      @origColor = "#513E37"
      @origOpacity = 0.3
      $(".nav-caption").addClass("dark")
    @pieces
      .attr("fill", @origColor)
      .attr("fill-opacity", @origOpacity)
    $(".nav-caption").addClass("dark")

  makePaths: (expand=false) ->
    # BOUND_SCALE is necessary because the circles aren't centered 
    # on the bottom right corner (this helps adjust the width of the svg)
    BOUND_SCALE = 0.927     
    bound = $("#nav-logo").width() * BOUND_SCALE
    center_offset = $("#nav-logo").width() * (1.05-BOUND_SCALE)
    numFrames = Gakko.numFrames
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
    angle_difference = Gakko.PI/2 - angle_extra
    interval = Gakko.PI/2 + 2*angle_difference

    Gakko.angleExtra = angle_extra
    Gakko.interval = interval

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
    outlines = []
    # numFrames times
    for i in [0...numFrames]
      path = "M #{big[i][0]},#{big[i][1]} A #{R},#{R} 0 0,0 #{big[i+1][0]}, #{big[i+1][1]} "
      path += "L #{small[i+1][0]}, #{small[i+1][1]} "
      path += "A #{r},#{r} 0 0,1 #{small[i][0]}, #{small[i][1]} Z"
      paths.push path

    outlines.push "M #{big[0][0]},#{big[0][1]} A #{R},#{R} \
0 0,0 #{big[numFrames][0]}, #{big[numFrames][1]}"
    outlines.push "M #{small[0][0]},#{small[0][1]} A #{r},#{r} \
0 0,0 #{small[numFrames][0]}, #{small[numFrames][1]}"
    return {
      paths: paths
      outlines: outlines
    }

  # Changes the placement and size of the nav-logo captions
  adjustCaptions: ->
    radius = $("#nav-logo").width()+30            # 30 was picked as a padding
    size = Gakko.map(radius, 120.0, 300.0, 10.0, 22.0)  # 120, 300 come from #nav-logo min and max-width.
    numFrames = Gakko.numFrames
    for num in [0...numFrames]
      step = Gakko.interval/numFrames
      angle = (num+0.5)*step + Gakko.angleExtra
      bottom = radius*Math.sin(angle).toFixed(3)
      if num is numFrames - 1
        toAdd = Gakko.map(radius, 120.0, 300.0, 3, 20)
        bottom += toAdd
      right = -radius*Math.cos(angle).toFixed(3)  # Negative because we're in quadrant II but measuring positively
      $("#cap-#{num}").css(
        fontSize: "#{size}px"
        lineHeight: "#{size}px"
        # width: "#{size*4.5}px"
        bottom: "#{bottom}px"
        right: "#{right+2*(numFrames - num)}px"   # Move right-most items more than away from edge of screen
      )
  setupNav: ->
    $("#nav-logo").height($("#nav-logo").width())
    result = Gakko.makePaths()
    expandedResult = Gakko.makePaths(true)
    Gakko.paths = result.paths
    Gakko.outlines = result.outlines
    Gakko.expandedPaths = expandedResult.paths
    Gakko.expandedOutlines = expandedResult.outlines
    for p, i in Gakko.pieces[0]
      d3.select(p).attr("d", Gakko.paths[i])
    # for o, i in Gakko.rings[0]
    #   d3.select(o).attr("d", Gakko.outlines[i])
    Gakko.adjustCaptions()
}                  