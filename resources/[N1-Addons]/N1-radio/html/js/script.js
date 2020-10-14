$(function() {
    window.addEventListener('message', function(event) {
        if (event.data.type == "open") {
            N1Radio.SlideUp()
        }

        if (event.data.type == "close") {
            N1Radio.SlideDown()
        }
    });

    document.onkeyup = function (data) {
        if (data.which == 27) { // Escape key
            $.post('http://N1-radio/escape', JSON.stringify({}));
            N1Radio.SlideDown()
        } else if (data.which == 13) { // Escape key
            $.post('http://N1-radio/joinRadio', JSON.stringify({
                channel: $("#channel").val()
            }));
        }
    };
});

N1Radio = {}

$(document).on('click', '#submit', function(e){
    e.preventDefault();

    $.post('http://N1-radio/joinRadio', JSON.stringify({
        channel: $("#channel").val()
    }));
});

$(document).on('click', '#disconnect', function(e){
    e.preventDefault();

    $.post('http://N1-radio/leaveRadio');
});

N1Radio.SlideUp = function() {
    $(".container").css("display", "block");
    $(".radio-container").animate({bottom: "6vh",}, 250);
}

N1Radio.SlideDown = function() {
    $(".radio-container").animate({bottom: "-110vh",}, 400, function(){
        $(".container").css("display", "none");
    });
}