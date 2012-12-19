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

# Draws two concentric circle-paths, to make the Gakko logo
# shrinkFactor must be a float <= 1
makePath = (shrinkFactor = 1) ->
  height = $("#nav-logo").height()
  half = height/2
  radius = half*shrinkFactor
  offset = half - radius

  smallRadius = radius * 0.6
  smallOffset = offset + (radius - smallRadius) * 0.5

  tail = "0 1,1 -0.1,0"         # Same thing appended to all paths...

  path = "M #{half},#{offset} a #{radius},#{radius} #{tail} \
M #{half},#{smallOffset} a #{smallRadius},#{smallRadius} #{tail}"
  path

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
  nav = d3.select("#logo-path")

  origPath = makePath(0.5)
  newPath = makePath(1)
  console.log origPath, "\n", nav.attr("d")
  nav.attr("d", origPath)

  origColor = nav.attr("fill")
  newColor = "rgba(187, 24, 24, 1)"

  $("#nav-logo").mouseenter(() ->
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

movePanel = (dir) ->
  return if window.currentFrame is 0 and dir is -1
  return if window.currentFrame is window.frames.length-1 and dir is 1
  return if window.scrolling
  window.scrolling = true
  window.currentFrame += dir
  panel = window.frames[window.currentFrame]
  # window.location.hash = panel
  top = $(panel).offset().top
  $("body,html,document").animate({"scrollTop": top}, window.time, ->
    setTimeout ->
      window.scrolling = false
    , window.time
  )

getNearestSize = (a, n) ->
  l = a.length
  return l - 1 if l < 2
  p = Math.abs(a[--l] - n)
  while l--
    break if p < (p = Math.abs(a[l] - n))
  l + 1

backstretchPages = ->
  w = $(window).width()
  backgroundList = [900, 1280, 1600, 2000]
  size = backgroundList[getNearestSize(backgroundList, w)]
  back = "images/background#{size}.jpg"
  team = "images/team#{size}.jpg"
  about = "images/about#{size}.jpg"
  apply = "images/apply2000.jpg"
  $.backstretch back,
    speed: 500

  $("#about").backstretch about
  $("#team").backstretch team
  $("#apply").backstretch apply
