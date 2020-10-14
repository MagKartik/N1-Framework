N1 = {}
N1.Phone = {}
N1.Screen = {}
N1.Phone.Functions = {}
N1.Phone.Animations = {}
N1.Phone.Notifications = {}
N1.Phone.ContactColors = {
    0: "#9b59b6",
    1: "#3498db",
    2: "#e67e22",
    3: "#e74c3c",
    4: "#1abc9c",
    5: "#9c88ff",
}

N1.Phone.Data = {
    currentApplication: null,
    PlayerData: {},
    Applications: {},
    IsOpen: false,
    CallActive: false,
    MetaData: {},
    PlayerJob: {},
    AnonymousCall: false,
}

N1.Phone.Data.MaxSlots = 16;

OpenedChatData = {
    number: null,
}

var CanOpenApp = true;

function IsAppJobBlocked(joblist, myjob) {
    var retval = false;
    if (joblist.length > 0) {
        $.each(joblist, function(i, job){
            if (job == myjob && N1.Phone.Data.PlayerData.job.onduty) {
                retval = true;
            }
        });
    }
    return retval;
}

N1.Phone.Functions.SetupApplications = function(data) {
    N1.Phone.Data.Applications = data.applications;

    var i;
    for (i = 1; i <= N1.Phone.Data.MaxSlots; i++) {
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+i+'"]');
        $(applicationSlot).html("");
        $(applicationSlot).css({
            "background-color":"transparent"
        });
        $(applicationSlot).prop('title', "");
        $(applicationSlot).removeData('app');
        $(applicationSlot).removeData('placement')
    }

    $.each(data.applications, function(i, app){
        var applicationSlot = $(".phone-applications").find('[data-appslot="'+app.slot+'"]');
        var blockedapp = IsAppJobBlocked(app.blockedjobs, N1.Phone.Data.PlayerJob.name)

        if ((!app.job || app.job === N1.Phone.Data.PlayerJob.name) && !blockedapp) {
            $(applicationSlot).css({"background-color":app.color});
            var icon = '<i class="ApplicationIcon '+app.icon+'" style="'+app.style+'"></i>';
            if (app.app == "meos") {
                icon = '<img src="./img/politie.png" class="police-icon">';
            }
            $(applicationSlot).html(icon+'<div class="app-unread-alerts">0</div>');
            $(applicationSlot).prop('title', app.tooltipText);
            $(applicationSlot).data('app', app.app);

            if (app.tooltipPos !== undefined) {
                $(applicationSlot).data('placement', app.tooltipPos)
            }
        }
    });

    $('[data-toggle="tooltip"]').tooltip();
}

N1.Phone.Functions.SetupAppWarnings = function(AppData) {
    $.each(AppData, function(i, app){
        var AppObject = $(".phone-applications").find("[data-appslot='"+app.slot+"']").find('.app-unread-alerts');

        if (app.Alerts > 0) {
            $(AppObject).html(app.Alerts);
            $(AppObject).css({"display":"block"});
        } else {
            $(AppObject).css({"display":"none"});
        }
    });
}

N1.Phone.Functions.IsAppHeaderAllowed = function(app) {
    var retval = true;
    $.each(Config.HeaderDisabledApps, function(i, blocked){
        if (app == blocked) {
            retval = false;
        }
    });
    return retval;
}

$(document).on('click', '.phone-application', function(e){
    e.preventDefault();
    var PressedApplication = $(this).data('app');
    var AppObject = $("."+PressedApplication+"-app");

    if (AppObject.length !== 0) {
        if (CanOpenApp) {
            if (N1.Phone.Data.currentApplication == null) {
                N1.Phone.Animations.TopSlideDown('.phone-application-container', 300, 0);
                N1.Phone.Functions.ToggleApp(PressedApplication, "block");
                
                if (N1.Phone.Functions.IsAppHeaderAllowed(PressedApplication)) {
                    N1.Phone.Functions.HeaderTextColor("black", 300);
                }
    
                N1.Phone.Data.currentApplication = PressedApplication;
    
                if (PressedApplication == "settings") {
                    $("#myPhoneNumber").text(N1.Phone.Data.PlayerData.charinfo.phone);
                    $("#mySerialNumber").text("N1-" + N1.Phone.Data.PlayerData.metadata["phonedata"].SerialNumber);
                } else if (PressedApplication == "twitter") {
                    $.post('http://N1-Phone /GetMentionedTweets', JSON.stringify({}), function(MentionedTweets){
                        N1.Phone.Notifications.LoadMentionedTweets(MentionedTweets)
                    })
                    $.post('http://N1-Phone /GetHashtags', JSON.stringify({}), function(Hashtags){
                        N1.Phone.Notifications.LoadHashtags(Hashtags)
                    })
                    if (N1.Phone.Data.IsOpen) {
                        $.post('http://N1-Phone /GetTweets', JSON.stringify({}), function(Tweets){
                            N1.Phone.Notifications.LoadTweets(Tweets);
                        });
                    }
                } else if (PressedApplication == "bank") {
                    N1.Phone.Functions.DoBankOpen();
                    $.post('http://N1-Phone /GetBankContacts', JSON.stringify({}), function(contacts){
                        N1.Phone.Functions.LoadContactsWithNumber(contacts);
                    });
                    $.post('http://N1-Phone /GetInvoices', JSON.stringify({}), function(invoices){
                        N1.Phone.Functions.LoadBankInvoices(invoices);
                    });
                } else if (PressedApplication == "whatsapp") {
                    $.post('http://N1-Phone /GetWhatsappChats', JSON.stringify({}), function(chats){
                        N1.Phone.Functions.LoadWhatsappChats(chats);
                    });
                } else if (PressedApplication == "phone") {
                    $.post('http://N1-Phone /GetMissedCalls', JSON.stringify({}), function(recent){
                        N1.Phone.Functions.SetupRecentCalls(recent);
                    });
                    $.post('http://N1-Phone /GetSuggestedContacts', JSON.stringify({}), function(suggested){
                        N1.Phone.Functions.SetupSuggestedContacts(suggested);
                    });
                    $.post('http://N1-Phone /ClearGeneralAlerts', JSON.stringify({
                        app: "phone"
                    }));
                } else if (PressedApplication == "mail") {
                    $.post('http://N1-Phone /GetMails', JSON.stringify({}), function(mails){
                        N1.Phone.Functions.SetupMails(mails);
                    });
                    $.post('http://N1-Phone /ClearGeneralAlerts', JSON.stringify({
                        app: "mail"
                    }));
                } else if (PressedApplication == "advert") {
                    $.post('http://N1-Phone /LoadAdverts', JSON.stringify({}), function(Adverts){
                        N1.Phone.Functions.RefreshAdverts(Adverts);
                    })
                } else if (PressedApplication == "garage") {
                    $.post('http://N1-Phone /SetupGarageVehicles', JSON.stringify({}), function(Vehicles){
                        SetupGarageVehicles(Vehicles);
                    })
                } else if (PressedApplication == "crypto") {
                    $.post('http://N1-Phone /GetCryptoData', JSON.stringify({
                        crypto: "N1it",
                    }), function(CryptoData){
                        SetupCryptoData(CryptoData);
                    })

                    $.post('http://N1-Phone /GetCryptoTransactions', JSON.stringify({}), function(data){
                        RefreshCryptoTransactions(data);
                    })
                } else if (PressedApplication == "racing") {
                    $.post('http://N1-Phone /GetAvailableRaces', JSON.stringify({}), function(Races){
                        SetupRaces(Races);
                    });
                } else if (PressedApplication == "houses") {
                    $.post('http://N1-Phone /GetPlayerHouses', JSON.stringify({}), function(Houses){
                        SetupPlayerHouses(Houses);
                    });
                    $.post('http://N1-Phone /GetPlayerKeys', JSON.stringify({}), function(Keys){
                        $(".house-app-mykeys-container").html("");
                        if (Keys.length > 0) {
                            $.each(Keys, function(i, key){
                                var elem = '<div class="mykeys-key" id="keyid-'+i+'"> <span class="mykeys-key-label">' + key.HouseData.adress + '</span> <span class="mykeys-key-sub">Klik om GPS in te stellen</span> </div>';

                                $(".house-app-mykeys-container").append(elem);
                                $("#keyid-"+i).data('KeyData', key);
                            });
                        }
                    });
                } else if (PressedApplication == "meos") {
                    SetupMeosHome();
                } else if (PressedApplication == "lawyers") {
                    $.post('http://N1-Phone /GetCurrentLawyers', JSON.stringify({}), function(data){
                        SetupLawyers(data);
                    });
                } else if (PressedApplication == "store") {
                    $.post('http://N1-Phone /SetupStoreApps', JSON.stringify({}), function(data){
                        SetupAppstore(data); 
                    });
                } else if (PressedApplication == "trucker") {
                    $.post('http://N1-Phone /GetTruckerData', JSON.stringify({}), function(data){
                        SetupTruckerInfo(data);
                    });
                }
            }
        }
    } else {
        N1.Phone.Notifications.Add("fas fa-exclamation-circle", "System", N1.Phone.Data.Applications[PressedApplication].tooltipText+" is not available!")
    }
});

$(document).on('click', '.mykeys-key', function(e){
    e.preventDefault();

    var KeyData = $(this).data('KeyData');

    $.post('http://N1-Phone /SetHouseLocation', JSON.stringify({
        HouseData: KeyData
    }))
});

$(document).on('click', '.phone-home-container', function(event){
    event.preventDefault();

    if (N1.Phone.Data.currentApplication === null) {
        N1.Phone.Functions.Close();
    } else {
        N1.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
        N1.Phone.Animations.TopSlideUp('.'+N1.Phone.Data.currentApplication+"-app", 400, -160);
        CanOpenApp = false;
        setTimeout(function(){
            N1.Phone.Functions.ToggleApp(N1.Phone.Data.currentApplication, "none");
            CanOpenApp = true;
        }, 400)
        N1.Phone.Functions.HeaderTextColor("white", 300);

        if (N1.Phone.Data.currentApplication == "whatsapp") {
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatPicture = null;
                    OpenedChatData.number = null;
                }, 450);
            }
        } else if (N1.Phone.Data.currentApplication == "bank") {
            if (CurrentTab == "invoices") {
                setTimeout(function(){
                    $(".bank-app-invoices").animate({"left": "30vh"});
                    $(".bank-app-invoices").css({"display":"none"})
                    $(".bank-app-accounts").css({"display":"block"})
                    $(".bank-app-accounts").css({"left": "0vh"});
    
                    var InvoicesObjectBank = $(".bank-app-header").find('[data-headertype="invoices"]');
                    var HomeObjectBank = $(".bank-app-header").find('[data-headertype="accounts"]');
    
                    $(InvoicesObjectBank).removeClass('bank-app-header-button-selected');
                    $(HomeObjectBank).addClass('bank-app-header-button-selected');
    
                    CurrentTab = "accounts";
                }, 400)
            }
        } else if (N1.Phone.Data.currentApplication == "meos") {
            $(".meos-alert-new").remove();
            setTimeout(function(){
                $(".meos-recent-alert").removeClass("noodknop");
                $(".meos-recent-alert").css({"background-color":"#004682"}); 
            }, 400)
        }

        N1.Phone.Data.currentApplication = null;
    }
});

N1.Phone.Functions.Open = function(data) {
    N1.Phone.Animations.BottomSlideUp('.container', 300, 0);
    N1.Phone.Notifications.LoadTweets(data.Tweets);
    N1.Phone.Data.IsOpen = true;
}

N1.Phone.Functions.ToggleApp = function(app, show) {
    $("."+app+"-app").css({"display":show});
}

N1.Phone.Functions.Close = function() {

    if (N1.Phone.Data.currentApplication == "whatsapp") {
        setTimeout(function(){
            N1.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
            N1.Phone.Animations.TopSlideUp('.'+N1.Phone.Data.currentApplication+"-app", 400, -160);
            $(".whatsapp-app").css({"display":"none"});
            N1.Phone.Functions.HeaderTextColor("white", 300);
    
            if (OpenedChatData.number !== null) {
                setTimeout(function(){
                    $(".whatsapp-chats").css({"display":"block"});
                    $(".whatsapp-chats").animate({
                        left: 0+"vh"
                    }, 1);
                    $(".whatsapp-openedchat").animate({
                        left: -30+"vh"
                    }, 1, function(){
                        $(".whatsapp-openedchat").css({"display":"none"});
                    });
                    OpenedChatData.number = null;
                }, 450);
            }
            OpenedChatPicture = null;
            N1.Phone.Data.currentApplication = null;
        }, 500)
    } else if (N1.Phone.Data.currentApplication == "meos") {
        $(".meos-alert-new").remove();
        $(".meos-recent-alert").removeClass("noodknop");
        $(".meos-recent-alert").css({"background-color":"#004682"}); 
    }

    N1.Phone.Animations.BottomSlideDown('.container', 300, -70);
    $.post('http://N1-Phone /Close');
    N1.Phone.Data.IsOpen = false;
}

N1.Phone.Functions.HeaderTextColor = function(newColor, Timeout) {
    $(".phone-header").animate({color: newColor}, Timeout);
}

N1.Phone.Animations.BottomSlideUp = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout);
}

N1.Phone.Animations.BottomSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        bottom: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

N1.Phone.Animations.TopSlideDown = function(Object, Timeout, Percentage) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout);
}

N1.Phone.Animations.TopSlideUp = function(Object, Timeout, Percentage, cb) {
    $(Object).css({'display':'block'}).animate({
        top: Percentage+"%",
    }, Timeout, function(){
        $(Object).css({'display':'none'});
    });
}

N1.Phone.Notifications.Add = function(icon, title, text, color, timeout) {
    $.post('http://N1-Phone /HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (timeout == null && timeout == undefined) {
                timeout = 1500;
            }
            if (N1.Phone.Notifications.Timeout == undefined || N1.Phone.Notifications.Timeout == null) {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else if (color == "default" || color == null || color == undefined) {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                N1.Phone.Animations.TopSlideDown(".phone-notification-container", 200, 8);
                if (icon !== "politie") {
                    $(".notification-icon").html('<i class="'+icon+'"></i>');
                } else {
                    $(".notification-icon").html('<img src="./img/politie.png" class="police-icon-notify">');
                }
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (N1.Phone.Notifications.Timeout !== undefined || N1.Phone.Notifications.Timeout !== null) {
                    clearTimeout(N1.Phone.Notifications.Timeout);
                }
                N1.Phone.Notifications.Timeout = setTimeout(function(){
                    N1.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    N1.Phone.Notifications.Timeout = null;
                }, timeout);
            } else {
                if (color != null || color != undefined) {
                    $(".notification-icon").css({"color":color});
                    $(".notification-title").css({"color":color});
                } else {
                    $(".notification-icon").css({"color":"#e74c3c"});
                    $(".notification-title").css({"color":"#e74c3c"});
                }
                $(".notification-icon").html('<i class="'+icon+'"></i>');
                $(".notification-title").html(title);
                $(".notification-text").html(text);
                if (N1.Phone.Notifications.Timeout !== undefined || N1.Phone.Notifications.Timeout !== null) {
                    clearTimeout(N1.Phone.Notifications.Timeout);
                }
                N1.Phone.Notifications.Timeout = setTimeout(function(){
                    N1.Phone.Animations.TopSlideUp(".phone-notification-container", 200, -8);
                    N1.Phone.Notifications.Timeout = null;
                }, timeout);
            }
        }
    });
}

N1.Phone.Functions.LoadPhoneData = function(data) {
    N1.Phone.Data.PlayerData = data.PlayerData;
    N1.Phone.Data.PlayerJob = data.PlayerJob;
    N1.Phone.Data.MetaData = data.PhoneData.MetaData;
    N1.Phone.Functions.LoadMetaData(data.PhoneData.MetaData);
    N1.Phone.Functions.LoadContacts(data.PhoneData.Contacts);
    N1.Phone.Functions.SetupApplications(data);
    console.log("Phone succesfully loaded!");
}

N1.Phone.Functions.UpdateTime = function(data) {    
    var NewDate = new Date();
    var NewHour = NewDate.getHours();
    var NewMinute = NewDate.getMinutes();
    var Minutessss = NewMinute;
    var Hourssssss = NewHour;
    if (NewHour < 10) {
        Hourssssss = "0" + Hourssssss;
    }
    if (NewMinute < 10) {
        Minutessss = "0" + NewMinute;
    }
    var MessageTime = Hourssssss + ":" + Minutessss

    $("#phone-time").html(MessageTime + " <span style='font-size: 1.1vh;'>" + data.InGameTime.hour + ":" + data.InGameTime.minute + "</span>");
}

var NotificationTimeout = null;

N1.Screen.Notification = function(title, content, icon, timeout, color) {
    $.post('http://N1-Phone /HasPhone', JSON.stringify({}), function(HasPhone){
        if (HasPhone) {
            if (color != null && color != undefined) {
                $(".screen-notifications-container").css({"background-color":color});
            }
            $(".screen-notification-icon").html('<i class="'+icon+'"></i>');
            $(".screen-notification-title").text(title);
            $(".screen-notification-content").text(content);
            $(".screen-notifications-container").css({'display':'block'}).animate({
                right: 5+"vh",
            }, 200);
        
            if (NotificationTimeout != null) {
                clearTimeout(NotificationTimeout);
            }
        
            NotificationTimeout = setTimeout(function(){
                $(".screen-notifications-container").animate({
                    right: -35+"vh",
                }, 200, function(){
                    $(".screen-notifications-container").css({'display':'none'});
                });
                NotificationTimeout = null;
            }, timeout);
        }
    });
}

// N1.Screen.Notification("Nieuwe Tweet", "Dit is een test tweet like #YOLO", "fab fa-twitter", 4000);

$(document).ready(function(){
    window.addEventListener('message', function(event) {
        switch(event.data.action) {
            case "open":
                N1.Phone.Functions.Open(event.data);
                N1.Phone.Functions.SetupAppWarnings(event.data.AppData);
                N1.Phone.Functions.SetupCurrentCall(event.data.CallData);
                N1.Phone.Data.IsOpen = true;
                N1.Phone.Data.PlayerData = event.data.PlayerData;
                break;
            // case "LoadPhoneApplications":
            //     N1.Phone.Functions.SetupApplications(event.data);
            //     break;
            case "LoadPhoneData":
                N1.Phone.Functions.LoadPhoneData(event.data);
                break;
            case "UpdateTime":
                N1.Phone.Functions.UpdateTime(event.data);
                break;
            case "Notification":
                N1.Screen.Notification(event.data.NotifyData.title, event.data.NotifyData.content, event.data.NotifyData.icon, event.data.NotifyData.timeout, event.data.NotifyData.color);
                break;
            case "PhoneNotification":
                N1.Phone.Notifications.Add(event.data.PhoneNotify.icon, event.data.PhoneNotify.title, event.data.PhoneNotify.text, event.data.PhoneNotify.color, event.data.PhoneNotify.timeout);
                break;
            case "RefreshAppAlerts":
                N1.Phone.Functions.SetupAppWarnings(event.data.AppData);                
                break;
            case "UpdateMentionedTweets":
                N1.Phone.Notifications.LoadMentionedTweets(event.data.Tweets);                
                break;
            case "UpdateBank":
                $(".bank-app-account-balance").html("&euro; "+event.data.NewBalance);
                $(".bank-app-account-balance").data('balance', event.data.NewBalance);
                break;
            case "UpdateChat":
                if (N1.Phone.Data.currentApplication == "whatsapp") {
                    if (OpenedChatData.number !== null && OpenedChatData.number == event.data.chatNumber) {
                        console.log('Chat reloaded')
                        N1.Phone.Functions.SetupChatMessages(event.data.chatData);
                    } else {
                        console.log('Chats reloaded')
                        N1.Phone.Functions.LoadWhatsappChats(event.data.Chats);
                    }
                }
                break;
            case "UpdateHashtags":
                N1.Phone.Notifications.LoadHashtags(event.data.Hashtags);
                break;
            case "RefreshWhatsappAlerts":
                N1.Phone.Functions.ReloadWhatsappAlerts(event.data.Chats);
                break;
            case "CancelOutgoingCall":
                $.post('http://N1-Phone /HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        CancelOutgoingCall();
                    }
                });
                break;
            case "IncomingCallAlert":
                $.post('http://N1-Phone /HasPhone', JSON.stringify({}), function(HasPhone){
                    if (HasPhone) {
                        IncomingCallAlert(event.data.CallData, event.data.Canceled, event.data.AnonymousCall);
                    }
                });
                break;
            case "SetupHomeCall":
                N1.Phone.Functions.SetupCurrentCall(event.data.CallData);
                break;
            case "AnswerCall":
                N1.Phone.Functions.AnswerCall(event.data.CallData);
                break;
            case "UpdateCallTime":
                var CallTime = event.data.Time;
                var date = new Date(null);
                date.setSeconds(CallTime);
                var timeString = date.toISOString().substr(11, 8);

                if (!N1.Phone.Data.IsOpen) {
                    if ($(".call-notifications").css("right") !== "52.1px") {
                        $(".call-notifications").css({"display":"block"});
                        $(".call-notifications").animate({right: 5+"vh"});
                    }
                    $(".call-notifications-title").html("In conversation ("+timeString+")");
                    $(".call-notifications-content").html("Calling with "+event.data.Name);
                    $(".call-notifications").removeClass('call-notifications-shake');
                } else {
                    $(".call-notifications").animate({
                        right: -35+"vh"
                    }, 400, function(){
                        $(".call-notifications").css({"display":"none"});
                    });
                }

                $(".phone-call-ongoing-time").html(timeString);
                $(".phone-currentcall-title").html("In conversation ("+timeString+")");
                break;
            case "CancelOngoingCall":
                $(".call-notifications").animate({right: -35+"vh"}, function(){
                    $(".call-notifications").css({"display":"none"});
                });
                N1.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                setTimeout(function(){
                    N1.Phone.Functions.ToggleApp("phone-call", "none");
                    $(".phone-application-container").css({"display":"none"});
                }, 400)
                N1.Phone.Functions.HeaderTextColor("white", 300);
    
                N1.Phone.Data.CallActive = false;
                N1.Phone.Data.currentApplication = null;
                break;
            case "RefreshContacts":
                N1.Phone.Functions.LoadContacts(event.data.Contacts);
                break;
            case "UpdateMails":
                N1.Phone.Functions.SetupMails(event.data.Mails);
                break;
            case "RefreshAdverts":
                if (N1.Phone.Data.currentApplication == "advert") {
                    N1.Phone.Functions.RefreshAdverts(event.data.Adverts);
                }
                break;
            case "AddPoliceAlert":
                AddPoliceAlert(event.data)
                break;
            case "UpdateApplications":
                N1.Phone.Data.PlayerJob = event.data.JobData;
                N1.Phone.Functions.SetupApplications(event.data);
                break;
            case "UpdateTransactions":
                RefreshCryptoTransactions(event.data);
                break;
            case "UpdateRacingApp":
                $.post('http://N1-Phone /GetAvailableRaces', JSON.stringify({}), function(Races){
                    SetupRaces(Races);
                });
                break;
            case "RefreshAlerts":
                N1.Phone.Functions.SetupAppWarnings(event.data.AppData);
                break;
        }
    })
});

$(document).on('keydown', function() {
    switch(event.keyCode) {
        case 27: // ESCAPE
            N1.Phone.Functions.Close();
            break;
    }
});

// N1.Phone.Functions.Open();