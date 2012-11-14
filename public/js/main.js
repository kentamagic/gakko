$(document).ready(function() {

      var w = $(window).width();
      var backgroundList = [ 900, 1280, 1600, 2000 ];
      b = "images/background"+backgroundList[getNearest(backgroundList, w)]+".jpg";
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

  $("form").submit(function(e) {
    $("#notices div").hide();
    e.preventDefault();

    if ($("form input#email").val() === "") {
      $("#notices #error").show();
    } else {
      $.post("/signup", $(this).serialize(), function() {
        $("#notices #success").show();
        $("form input#email").val("");
      })
      .error(function() {
        $("#notices #error").show();
      });
    }
  });
});