$(document).ready(function() {

      var w = $(window).width();
      var backgroundList = [ 900, 1280, 1600, 2000 ];
      b = "img/background"+backgroundList[getNearest(backgroundList, w)]+".jpg";
      $.backstretch(b, {speed: 500});

      if(!Modernizr.input.placeholder){
      
        $('[placeholder]').focus(function() {
          var input = $(this);
          if (input.val() == input.attr('placeholder')) {
          input.val('');
          input.removeClass('placeholder');
          }
        }).blur(function() {
          var input = $(this);
          if (input.val() == '' || input.val() == input.attr('placeholder')) {
          input.addClass('placeholder');
          input.val(input.attr('placeholder'));
          }
        }).blur();
        $('[placeholder]').parents('form').submit(function() {
          $(this).find('[placeholder]').each(function() {
          var input = $(this);
          if (input.val() == input.attr('placeholder')) {
            input.val('');
          }
          })
        });
      
      }

      $("#logo")
        .mouseover(function() { 
            var src = $(this).attr("src").match(/[^\.]+/) + "hover.png";
            $(this).attr("src", src);
        })
        .mouseout(function() {
            var src = $(this).attr("src").replace("hover.png", ".png");
            $(this).attr("src", src);
        });

 $("form").submit(function(e) {
    $("#mce-responses").hide();
    e.preventDefault();

    if ($("form input#mce-EMAIL").val() === "") {
      $("#mce-error-response").show();
    } else {
      var emailAddress = $("form input#mce-EMAIL").val();
      $.post("/signup", {email: emailAddress}, function() {
        $("#success").show();
        $("form input").hide();
        $('.submit-button').css('background', "#26b78c url('../img/success.png') center no-repeat");
      })
      .error(function() {
        $("form input").attr('placeholder', 'Please try again...');
        $("form input#mce-EMAIL").val('');
        $('.submit-button').css('background', "#a51d21 url('../img/error.png') center no-repeat");
      });
    }
  });
  
  $('form input').focus(function() {
    $('.submit-button').css('background', "#ffc600 url('../img/right.png') center no-repeat");
  });
});