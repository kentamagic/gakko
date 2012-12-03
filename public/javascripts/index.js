function backstretchPages() {
	var w = $(window).width();
	var backgroundList = [ 900, 1280, 1600, 2000 ];
	var size = backgroundList[getNearest(backgroundList, w)];
	b = "images/background"+size+".jpg";
	t = "images/team"+size+".jpg";
	a = "images/about"+size+".jpg";
	apply = "images/apply"+2000+".jpg";
	$.backstretch(b, {speed: 500});
	$("#about").backstretch(a);
	$("#team").backstretch(t);
	$("#apply").backstretch(apply);
}


function formSubmit() {
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
				$('.submit-button').css('background', "#26b78c url('images/success.png') center no-repeat");
			})
			.error(function() {
				$("form input").attr('placeholder', 'Please try again...');
				$("form input#mce-EMAIL").val('');
				$('.submit-button').css('background', "#a51d21 url('images/error.png') center no-repeat");
			});
		}
	});
	
	$('form input').focus(function() {
		$('.submit-button').css('background', "#9e8f88 url('images/right.png') center no-repeat");
	});
}

function tweet() {
	$('.tweet').tweet({
          avatar_size: 32,
          count: 1,
          username: "gakkoproject",
          template: "{text}"
        });
}

function aboutControls() {

	subcont_index = 0;
	subconts = $(".asubcont");

	$("#next").click(function() {
		$("#id1, #id2").removeClass("selected");
		subcont_index = (subcont_index+1)%subconts.length;
		$("#id"+(subcont_index+1)).addClass("selected");
		$(".asubcont").addClass("hide");
		$(subconts[subcont_index]).removeClass("hide");
	});
	$("#previous").click(function() {
		$("#id1, #id2").removeClass("selected");
		subcont_index = (subcont_index+(subconts.length-1))%subconts.length;
		$("#id"+(subcont_index+1)).addClass("selected");
		$(".asubcont").addClass("hide");
		$(subconts[subcont_index]).removeClass("hide");
	});
	$("#id1").click(function() {
		$("#id1, #id2").removeClass("selected");
		subcont_index = 0;
		$("#id"+(subcont_index+1)).addClass("selected");
		$(".asubcont").addClass("hide");
		$(subconts[subcont_index]).removeClass("hide");
	});
	$("#id2").click(function() {
		$("#id1, #id2").removeClass("selected");
		subcont_index = 1;
		$("#id"+(subcont_index+1)).addClass("selected");
		$(".asubcont").addClass("hide");
		$(subconts[subcont_index]).removeClass("hide");
	});
}

$(document).ready(function() {
	formSubmit();
	backstretchPages();
	aboutControls();
	tweet();
});