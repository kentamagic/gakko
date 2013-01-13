# Define Gakko
window.Gakko = Gakko = {
  # Constants
  PI: 3.14159265358
  numFrames: 6                    # Number of nav items
  interval: @PI/2                 # The angle interval on the nav-logo circle
  extraAngle: 0

  # Variables
  scrolling: false                # Is the window scrolling? (bc of me)
  paths: []                       # The arrays where the nav-logo shapes/outlines are stored
  expandedPaths: []
  outlines: []
  expandedOutlines: []            # The current window 'panel' being shown
  backIndex: 0
  linkDests: {}                   # Destination containers for fancybox nav links
  linkIndexes: [0, 6, 18, 36]     # Indexes for jumping to in fancybox

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
    # if num <= 2
    #   newIndex = Math.floor num/2 
    # else
    newIndex = Math.floor (num)/2
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
    else
      @origColor = "#513E37"
      @origOpacity = 0.3
      $(".nav-caption").addClass("dark")
    @pieces
      .attr("fill", @origColor)
      .attr("fill-opacity", @origOpacity)

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
    # size: 120, 300 come from #nav-logo min and max-width.
    size = Gakko.map(radius, 120.0, 300.0, 10.0, 22.0)  
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

  setNavEventHandlers: ->
    # Navigation animation 
    duration = 200
    $("#nav-logo").mouseenter( ->
      $("#nav-captions").fadeIn("fast")
      for p, i in Gakko.pieces[0]
        d3.select(p)
          .transition().duration(duration)
          .attr("d", Gakko.expandedPaths[i])
    ).mouseleave( ->
      $("#nav-captions").fadeOut("fast")
      for p, i in Gakko.pieces[0]
        d3.select(p)
          .transition().duration(duration)
          .attr("d", Gakko.paths[i])
    )
    newColor = "#B82025"
    Gakko.pieces.on("mousemove", ->
      d3.select(this)
        .attr("fill", newColor)
        .attr("fill-opacity", 1)
      id = d3.select(this).attr("target")
      $("#cap-#{id}").addClass("highlight")
    ).on("mouseout", ->
      d3.select(this)
        .attr("fill", Gakko.origColor)
        .attr("fill-opacity", Gakko.origOpacity)
      id = d3.select(this).attr("target")
      $("#cap-#{id}").removeClass("highlight")
    )
    # Navigation click
    $(".js-nav").click ->
      Gakko.scrolling = true
      id = parseInt(d3.select(this).attr("target"))
      # Manually setting id because 2013 page has two parts
      id = 6 if id is 5 
      from = $("body").scrollTop()
      dest = $($(".panel")[id]).offset().top
      # Time depends on distance (so speed is constant)
      time = Math.abs(dest-from)/3 + 100
      $("body,html,document").animate
        scrollTop: dest+10
      , time, ->
        Gakko.scrolling = false
        Gakko.navColorShift()
      true

  setupFancybox: ->
    $(".fancybox-thumb").fancybox(
      padding: 0
      margin: 0#[100, 0, 100, 0]
      maxWidth: "90%"
      maxHeight: "85%"
      topRatio: 1
      beforeLoad: ->
        this.title = $(this.element).attr "caption"
        $("#fancy-overlay").show()
        $("#nav-container").hide()
        Gakko.makeFancyboxNav()
        $("body").css "overflow", "hidden"
        true
      beforeShow: ->
        $(".twelve-link").removeClass("selected")
        links = Gakko.linkIndexes
        l = links.length
        for i in [l-1..0]
          if $.fancybox.current.index >= links[i]
            $($(".twelve-link")[i]).addClass("selected")
            break
        true
      afterClose: -> 
        $("#fancy-overlay").hide()
        Gakko.removeFancyboxNav()
        $("#nav-container").show()
        $(".twelve-link.selected").removeClass "selected"
        $("body").css "overflow", "visible"
        true
      helpers:
        title:
          type: 'over'
        thumbs: 
          width: 50
          height: 50
        overlay: null
    )

  makeFancyboxNav: ->
    as = $("a.fancybox-thumb:not(.hide)")
    for i in [0...@linkIndexes.length]
      a = $(as)[i]
      string = "javascript:jQuery.fancybox.jumpto(#{@linkIndexes[i]});"
      $(a).attr "href", string
    $(as).removeClass('fancybox-thumb').addClass('fancybox-thumb-inactive')

  removeFancyboxNav: ->
    as = $("a.fancybox-thumb-inactive:not(.hide)")
    for i in [0...@linkIndexes.length]
      a = $(as)[i]
      $(a).attr "href", @linkDests[i]
    $(as).removeClass('fancybox-thumb-inactive').addClass('fancybox-thumb')
    @setupFancybox()
}                  