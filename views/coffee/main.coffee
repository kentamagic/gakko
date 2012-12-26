Gakko = window.Gakko
$(document).ready ->
  $.fn.smartbg = (url, time, cb) ->
    t = this
    # create an img so the browser will download the image: 
    $("<img />").attr("src", url).load ->
      $(t).css "backgroundImage", "url(#{url})"
      $(t).fadeIn time, ->
        cb t if typeof cb is "function"
    this
  # Setup
  bImages = [
    "background2000.jpg",
    "about2000.jpg",
    "connect_small.jpg",
    "apply2000.jpg",
  ]
  for b, i in $(".back")
    $(b).smartbg("/images/backgrounds/#{bImages[i]}", 200) 
  Gakko.pieces = d3.selectAll(".nav-piece")
  Gakko.rings = d3.selectAll(".nav-outline")
  origColor = "black"
  origColor = "#513E37"
  origOpacity = 0.3
  newColor = "#B82025"
  Gakko.pieces
    .attr("fill", origColor)
    .attr("fill-opacity", origOpacity)
  Gakko.setupNav()                   # The rest, which is also done in window.resize
  # Fade the logo in
  setTimeout( ->
    $(".logo").toggleClass "hidden"
  , 500)
  # Window events
  $(window).scroll(() ->
    Gakko.backShift()
  ).resize(() ->
    Gakko.setupNav()
  )
  # Navigation animation 
  duration = 200
  $("#nav-logo").mouseenter(() ->
    $("#nav-captions").fadeIn("fast")
    for p, i in Gakko.pieces[0]
      d3.select(p)
        .transition().duration(duration)
        .attr("d", Gakko.expandedPaths[i])
    for o, i in Gakko.rings[0]
      d3.select(o)
        .transition().duration(duration)
        .attr("d", Gakko.expandedOutlines[i])
  ).mouseleave(() ->
    $("#nav-captions").fadeOut("fast")
    for p, i in Gakko.pieces[0]
      d3.select(p)
        .transition().duration(duration)
        .attr("d", Gakko.paths[i])
    for o, i in Gakko.rings[0]
      d3.select(o)
        .transition().duration(duration)
        .attr("d", Gakko.outlines[i])
  )

  Gakko.pieces.on("mouseover", ->
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
