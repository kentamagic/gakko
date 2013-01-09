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
    "group2000.jpg",
    "apply2000.jpg",
    "background2000.jpg",
  ]
  for b, i in $(".back")
    $(b).smartbg("/images/backgrounds/#{bImages[i]}", 200) 
  Gakko.pieces = d3.selectAll(".nav-piece")
  # Gakko.rings = d3.selectAll(".nav-outline")
  Gakko.setupNav()                   # The rest, which is also done in window.resize
  # Fade the logo in
  setTimeout( ->
    $(".logo").toggleClass "hidden"
  , 500)
  # Window events -- make sure to change in Gakko.setupFancybox too!
  $(window).scroll(->
    Gakko.backShift()
    Gakko.navColorShift() if not Gakko.scrolling
  ).resize(->
    Gakko.setupNav()
  )
  $(window).scroll()
  # Navigation animation 
  duration = 200
  $("#nav-logo").mouseenter(() ->
    $("#nav-captions").fadeIn("fast")
    for p, i in Gakko.pieces[0]
      d3.select(p)
        .transition().duration(duration)
        .attr("d", Gakko.expandedPaths[i])
    # for o, i in Gakko.rings[0]
    #   d3.select(o)
    #     .transition().duration(duration)
    #     .attr("d", Gakko.expandedOutlines[i])
  ).mouseleave(() ->
    $("#nav-captions").fadeOut("fast")
    for p, i in Gakko.pieces[0]
      d3.select(p)
        .transition().duration(duration)
        .attr("d", Gakko.paths[i])
    # for o, i in Gakko.rings[0]
    #   d3.select(o)
    #     .transition().duration(duration)
    #     .attr("d", Gakko.outlines[i])
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
  $(".js-nav").click( ->
    Gakko.scrolling = true
    id = parseInt(d3.select(this).attr("target"))
    id = 6 if id is 5
    from = $("body").scrollTop()
    dest = $($(".panel")[id]).offset().top
    time = Math.abs(dest-from)/3 + 100
    $("body,html,document").animate(
      scrollTop: dest+10
    , time, ->
      Gakko.scrolling = false
      Gakko.navColorShift()
    )
    true
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

  # 2012 page

  # $(".twelve-link").click ->
  #   if not $(this).hasClass "selected"
  #     $(".twelve-link.selected").removeClass "selected"
  #     $(this).addClass "selected"
  for a, i in $("a.fancybox-thumb:not(.hide)")
    Gakko.linkDests[i] = $(a).attr "href"
  $("#fancy-overlay").click ->
    $.fancybox.close()
    $(this).hide()
  Gakko.setupFancybox()
