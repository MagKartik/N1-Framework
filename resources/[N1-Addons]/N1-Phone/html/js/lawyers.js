SetupLawyers = function(data) {
    $(".lawyers-list").html("");

    if (data.length > 0) {
        $.each(data, function(i, lawyer){
            var element = '<div class="lawyer-list" id="lawyerid-'+i+'"> <div class="lawyer-list-firstletter">' + (lawyer.name).charAt(0).toUpperCase() + '</div> <div class="lawyer-list-fullname">' + lawyer.name + '</div> <div class="lawyer-list-call"><i class="fas fa-phone"></i></div> </div>'
            $(".lawyers-list").append(element);
            $("#lawyerid-"+i).data('LawyerData', lawyer);
        });
    } else {
        var element = '<div class="lawyer-list"><div class="no-lawyers">There are no lawyers available.</div></div>'
        $(".lawyers-list").append(element);
    }
}

$(document).on('click', '.lawyer-list-call', function(e){
    e.preventDefault();

    var LawyerData = $(this).parent().data('LawyerData');
    
    var cData = {
        number: LawyerData.phone,
        name: LawyerData.name
    }

    $.post('http://N1-Phone /CallContact', JSON.stringify({
        ContactData: cData,
        Anonymous: N1.Phone.Data.AnonymousCall,
    }), function(status){
        if (cData.number !== N1.Phone.Data.PlayerData.charinfo.phone) {
            if (status.IsOnline) {
                if (status.CanCall) {
                    if (!status.InCall) {
                        if (N1.Phone.Data.AnonymousCall) {
                            N1.Phone.Notifications.Add("fas fa-phone", "Phone", "You started a anonymous call!");
                        }
                        $(".phone-call-outgoing").css({"display":"block"});
                        $(".phone-call-incoming").css({"display":"none"});
                        $(".phone-call-ongoing").css({"display":"none"});
                        $(".phone-call-outgoing-caller").html(cData.name);
                        N1.Phone.Functions.HeaderTextColor("white", 400);
                        N1.Phone.Animations.TopSlideUp('.phone-application-container', 400, -160);
                        setTimeout(function(){
                            $(".lawyers-app").css({"display":"none"});
                            N1.Phone.Animations.TopSlideDown('.phone-application-container', 400, 0);
                            N1.Phone.Functions.ToggleApp("phone-call", "block");
                        }, 450);
    
                        CallData.name = cData.name;
                        CallData.number = cData.number;
                    
                        N1.Phone.Data.currentApplication = "phone-call";
                    } else {
                        N1.Phone.Notifications.Add("fas fa-phone", "Phone", "You are already connected to a call!");
                    }
                } else {
                    N1.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is already in a call");
                }
            } else {
                N1.Phone.Notifications.Add("fas fa-phone", "Phone", "This person is not available!");
            }
        } else {
            N1.Phone.Notifications.Add("fas fa-phone", "Phone", "You can't call your own number!");
        }
    });
});