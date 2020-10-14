$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESC
            //Inventory.Close();
            break;
    }
});

var moneyTimeout = null;
var CurrentProx = 0;

(() => {
    N1Hud = {};

    N1Hud.Open = function(data) {
        $(".money-cash").css("display", "block");
        // $(".money-bank").css("display", "block");
        $("#cash").html(data.cash);
        // $("#bank").html(data.bank);
    };

    N1Hud.Close = function() {

    };

    N1Hud.Show = function(data) {
        if(data.type == "cash") {
            $(".money-cash").fadeIn(150);
            //$(".money-cash").css("display", "block");
            $("#cash").html(data.cash);
            setTimeout(function() {
                $(".money-cash").fadeOut(750);
            }, 3500)
        } //else if(data.type == "bank") {
            // $(".money-bank").fadeIn(150);
            // $(".money-bank").css("display", "block");
            // $("#bank").html(data.bank);
            // setTimeout(function() {
            //     $(".money-bank").fadeOut(750);
            // }, 3500)
        //}
    };

    N1Hud.ToggleSeatbelt = function(data) {
        if (data.seatbelt) {
            $(".car-seatbelt-info img").attr('src', './seatbelt-on.png');
        } else {
            $(".car-seatbelt-info img").attr('src', './seatbelt.png');
        }
    };

    N1Hud.ToggleHarness = function(data) {
        if (data.toggle) {
            $(".car-seatbelt-info").html('&nbsp;&nbsp;&nbsp;&nbsp;<span class="seatbelt-text">Harnas</div>');
        } else {
            $(".car-seatbelt-info").html('&nbsp;&nbsp;&nbsp;&nbsp;<img src="./seatbelt-on.png">');
        }
    }

    N1Hud.UpdateNitrous = function(data) {
        if (data.toggle) {
            if (data.active) {
                $("#nos-amount").css({"color":"#fcb80a"});
            } else {
                $("#nos-amount").css({"color":"#fff"});
            }
            $("#nos-amount").html(data.level);
        } else {
            $("#nos-amount").html("0");
            $("#nos-amount").css({"color":"#fff"});
        }
    }

    N1Hud.CarHud = function(data) {
        if (data.show) {
            $(".ui-car-container").fadeIn();
        } else {
            $(".ui-car-container").fadeOut();
        }
    };

    N1Hud.UpdateHud = function(data) {
        var Show = "block";
        if (data.show) {
            Show = "none";
            $(".ui-container").css("display", Show);
            return;
        }
        $(".ui-container").css("display", Show);

        // HP Bar
        // $(".ui-healthbar").find('.ui-barfill').css("width", data.health - 100 + "%");
        // $(".ui-armorbar").find('.ui-barfill').css("width", data.armor + "%");
        // $(".ui-foodbar").find('.ui-smallbarfill').css("height", data.hunger + "%");
        // $(".ui-thirstbar").find('.ui-smallbarfill').css("height", data.thirst + "%");
        // $(".ui-stressbar").find('.ui-smallbarfill').css("height", data.stress + "%");
        // $(".ui-bleedbar").find('.ui-smallbarfill').css("height", data.bleeding + "%");

        $("#boxSetHealth").css("width", data.health + "%");
        $("#boxSetArmour").css("width", data.armor + "%");
        widthHeightSplit(data.hunger, $("#boxSetHunger"));
        widthHeightSplit(data.thirst, $("#boxSetThirst"));
        widthHeightSplit(data.bleeding, $("#boxSetOxygen"));
        widthHeightSplit(data.stress, $("#boxSetStress"));

        $('.time-text').html(data.time.hour + ':' + data.time.minute);
        $("#fuel-amount").html((data.fuel).toFixed(0));
        $("#speed-amount").html(data.speed);

        if (data.street2 != "" && data.street2 != undefined) {
            $(".ui-car-street").html(data.street1 + ' | ' + data.street2 + ' | ' + data.area_zone);
        } else {
            $(".ui-car-street").html(data.street1 + ' | ' + data.area_zone);
        }

        if (data.engine < 600) {
            $(".car-engine-info img").attr('src', './engine-red.png');
            $(".car-engine-info").fadeIn(150);
        } else if (data.engine < 800) {
            $(".car-engine-info img").attr('src', './engine.png');
            $(".car-engine-info").fadeIn(150);
        } else {
            if ($(".car-engine-info").is(":visible")) {
                $(".car-engine-info").fadeOut(150);
            }
        }
    };

    N1Hud.UpdateProximity = function(data) {
        if (data.prox == 1) {
            $("[data-voicetype='1']").fadeIn(150);
            $("[data-voicetype='2']").fadeOut(150);
            $("[data-voicetype='3']").fadeOut(150);
        } else if (data.prox == 2) {
            $("[data-voicetype='1']").fadeIn(150);
            $("[data-voicetype='2']").fadeIn(150);
            $("[data-voicetype='3']").fadeOut(150);
        } else if (data.prox == 3) {
            $("[data-voicetype='1']").fadeIn(150);
            $("[data-voicetype='2']").fadeIn(150);
            $("[data-voicetype='3']").fadeIn(150);
        }
        CurrentProx = data.prox;
    }

    N1Hud.SetTalkingState = function(data) {
        if (!data.IsTalking) {
            $(".voice-block").animate({"background-color": "rgb(255, 255, 255)"}, 150);
        } else {
            $(".voice-block").animate({"background-color": "#fc4e03"}, 150);
        }
    }

    N1Hud.Update = function(data) {
        if(data.type == "cash") {
            $(".money-cash").css("display", "block");
            $("#cash").html(data.cash);
            if (data.minus) {
                $(".money-cash").append('<p class="moneyupdate minus">-<span id="cash-symbol">&euro;&nbsp;</span><span><span id="minus-changeamount">' + data.amount + '</span></span></p>')
                $(".minus").css("display", "block");
                setTimeout(function() {
                    $(".minus").fadeOut(750, function() {
                        $(".minus").remove();
                        $(".money-cash").fadeOut(750);
                    });
                }, 3500)
            } else {
                $(".money-cash").append('<p class="moneyupdate plus">+<span id="cash-symbol">&euro;&nbsp;</span><span><span id="plus-changeamount">' + data.amount + '</span></span></p>')
                $(".plus").css("display", "block");
                setTimeout(function() {
                    $(".plus").fadeOut(750, function() {
                        $(".plus").remove();
                        $(".money-cash").fadeOut(750);
                    });
                }, 3500)
            }
        }
    };

    N1Hud.UpdateCompass = function(data) {
        var amt = (data.heading * 0.1133333333333333);
        if (data.lookside == "left") {
            $(".compass-ui").css({
                "right": (-30.6 - amt) + "vh"
            });
        } else {
            $(".compass-ui").css({
                "right": (-30.6 + -amt) + "vh"
            });
        }
    }

    N1Hud.UpdateMeters = function(data) {
        var str = data.amount.toString();
        var l = str.length;
        $(".meters-text").html(data.amount + " <span style='position: relative; top: -.49vh; font-size: 1.2vh;'>km</span>");
    }

    function widthHeightSplit(value, ele) {
        let height = 35.5;
        let eleHeight = (value / 100) * height;
        let leftOverHeight = height - eleHeight;
    
        ele.css("width", eleHeight + "px");
       // ele.css("right", leftOverHeight + "px");
    };

    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch(event.data.action) {
                case "open":
                    N1Hud.Open(event.data);
                    break;
                case "close":
                    N1Hud.Close();
                    break;
                case "update":
                    N1Hud.Update(event.data);
                    break;
                case "show":
                    N1Hud.Show(event.data);
                    break;
                case "hudtick":
                    N1Hud.UpdateHud(event.data);
                    break;
                case "car":
                    N1Hud.CarHud(event.data);
                    break;
                case "seatbelt":
                    N1Hud.ToggleSeatbelt(event.data);
                    break;
                case "harness":
                    N1Hud.ToggleHarness(event.data);
                    break;
                case "nitrous":
                    N1Hud.UpdateNitrous(event.data);
                    break;
                case "proximity":
                    N1Hud.UpdateProximity(event.data);
                    break;
                case "talking":
                    N1Hud.SetTalkingState(event.data);
                    break;
                case "UpdateCompass":
                    N1Hud.UpdateCompass(event.data);
                    break;
                case "UpdateDrivingMeters":
                    N1Hud.UpdateMeters(event.data);
                    break;

            }
        })
    }

})();