$(document).ready ->
  # backstretchPages()
  setTimeout( ->
    $(".logo").toggleClass "transparent"
  , 500)
  bImages = {
    0: "background2000.jpg"
    1: "about2000.jpg"
    2: "connect_small.jpg"
  }
  index = 0
  $(window).bind('mousewheel', () ->
    top = $("body").scrollTop()
    height = $(".panel").height()
    tempIndex = Math.floor(Math.abs(top)/height)
    newIndex = Math.floor((tempIndex+1)/2)
    if newIndex isnt index
      newImg = bImages[newIndex]
      # console.log newImg, "t, h, ni: ", top, height, newIndex
      if newImg
        $("body").css("backgroundImage", "url(/images/backgrounds/#{newImg})");
        index = newIndex
        
  )
  ###
  window.scrolling = false
  window.time = 500
  window.frames = [
    '#home'
    '#about'
    '#team'
  ]
  # hash = window.location.hash
  window.currentFrame = 0 # window.frames.indexOf hash
  if window.currentFrame is -1
    window.currentFrame = 0
    window.location.hash = window.frames[0]

  $(window).bind('mousewheel', (e, d) ->
    e.preventDefault()
    dir = -1
    dir = 1 if d < 0
    movePanel(dir)
  )
  $(window).keydown((e) ->
    if e.which is 38 # up
      e.preventDefault()
      movePanel(-1)
    else if e.which is 40 # down
      e.preventDefault()
      movePanel(1)
  )
###

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
