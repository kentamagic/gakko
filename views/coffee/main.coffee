Gakko = window.Gakko
$(document).ready ->
  # Global scripts
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
  # Load large background images separately
  for b, i in $(".back")
    $(b).smartbg("/images/backgrounds/#{bImages[i]}", 200) 

  # Get nav elements
  Gakko.pieces = d3.selectAll(".nav-piece")
  Gakko.setupNav()                    # The rest, which is also done in window.resize
  Gakko.setNavEventHandlers()         # Only done once
  # Fade the logo in
  setTimeout( ->
    $(".logo").toggleClass "hidden"
  , 500)
  # Window events
  $(window).scroll( ->
    Gakko.backShift()
    Gakko.navColorShift() if not Gakko.scrolling
  ).resize ->
    Gakko.setupNav()
    $.fancybox.close()

  # Trigger scroll events
  $(window).scroll()

  # About page

  $(".about-link").click ->
    if not $(this).hasClass "selected"
      $(".about-link.selected").removeClass "selected"
      $(".about-content.shown").removeClass "shown"
      target = $(this).attr "target"
      $(this).addClass "selected"
      $(".about-content.#{target}").addClass "shown"

  # 2012 page

  # Store nav fancybox links for later
  for a, i in $("a.fancybox-thumb:not(.hide)")
    Gakko.linkDests[i] = $(a).attr "href"
  $("#fancy-overlay").click ->
    $.fancybox.close()
    $(this).hide()
  Gakko.setupFancybox()
