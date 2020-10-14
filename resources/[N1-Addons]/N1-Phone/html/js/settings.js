N1.Phone.Settings = {};
N1.Phone.Settings.Background = "default-N1us";
N1.Phone.Settings.OpenedTab = null;
N1.Phone.Settings.Backgrounds = {
    'default-N1us': {
        label: "Standard N1us"
    }
};

var PressedBackground = null;
var PressedBackgroundObject = null;
var OldBackground = null;
var IsChecked = null;

$(document).on('click', '.settings-app-tab', function(e){
    e.preventDefault();
    var PressedTab = $(this).data("settingstab");

    if (PressedTab == "background") {
        N1.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        N1.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "profilepicture") {
        N1.Phone.Animations.TopSlideDown(".settings-"+PressedTab+"-tab", 200, 0);
        N1.Phone.Settings.OpenedTab = PressedTab;
    } else if (PressedTab == "numberrecognition") {
        var checkBoxes = $(".numberrec-box");
        N1.Phone.Data.AnonymousCall = !checkBoxes.prop("checked");
        checkBoxes.prop("checked", N1.Phone.Data.AnonymousCall);

        if (!N1.Phone.Data.AnonymousCall) {
            $("#numberrecognition > p").html('Off');
        } else {
            $("#numberrecognition > p").html('On');
        }
    }
});

$(document).on('click', '#accept-background', function(e){
    e.preventDefault();
    var hasCustomBackground = N1.Phone.Functions.IsBackgroundCustom();

    if (hasCustomBackground === false) {
        N1.Phone.Notifications.Add("fas fa-paint-brush", "Settings", N1.Phone.Settings.Backgrounds[N1.Phone.Settings.Background].label+" is ingesteld!")
        N1.Phone.Animations.TopSlideUp(".settings-"+N1.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+N1.Phone.Settings.Background+".png')"})
    } else {
        N1.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal background set!")
        N1.Phone.Animations.TopSlideUp(".settings-"+N1.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $(".phone-background").css({"background-image":"url('"+N1.Phone.Settings.Background+"')"});
    }

    $.post('http://N1-Phone /SetBackground', JSON.stringify({
        background: N1.Phone.Settings.Background,
    }))
});

N1.Phone.Functions.LoadMetaData = function(MetaData) {
    if (MetaData.background !== null && MetaData.background !== undefined) {
        N1.Phone.Settings.Background = MetaData.background;
    } else {
        N1.Phone.Settings.Background = "default-N1us";
    }

    var hasCustomBackground = N1.Phone.Functions.IsBackgroundCustom();

    if (!hasCustomBackground) {
        $(".phone-background").css({"background-image":"url('/html/img/backgrounds/"+N1.Phone.Settings.Background+".png')"})
    } else {
        $(".phone-background").css({"background-image":"url('"+N1.Phone.Settings.Background+"')"});
    }

    if (MetaData.profilepicture == "default") {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+MetaData.profilepicture+'">');
    }
}

$(document).on('click', '#cancel-background', function(e){
    e.preventDefault();
    N1.Phone.Animations.TopSlideUp(".settings-"+N1.Phone.Settings.OpenedTab+"-tab", 200, -100);
});

N1.Phone.Functions.IsBackgroundCustom = function() {
    var retval = true;
    $.each(N1.Phone.Settings.Backgrounds, function(i, background){
        if (N1.Phone.Settings.Background == i) {
            retval = false;
        }
    });
    return retval
}

$(document).on('click', '.background-option', function(e){
    e.preventDefault();
    PressedBackground = $(this).data('background');
    PressedBackgroundObject = this;
    OldBackground = $(this).parent().find('.background-option-current');
    IsChecked = $(this).find('.background-option-current');

    if (IsChecked.length === 0) {
        if (PressedBackground != "custom-background") {
            N1.Phone.Settings.Background = PressedBackground;
            $(OldBackground).fadeOut(50, function(){
                $(OldBackground).remove();
            });
            $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            N1.Phone.Animations.TopSlideDown(".background-custom", 200, 13);
        }
    }
});

$(document).on('click', '#accept-custom-background', function(e){
    e.preventDefault();

    N1.Phone.Settings.Background = $(".custom-background-input").val();
    $(OldBackground).fadeOut(50, function(){
        $(OldBackground).remove();
    });
    $(PressedBackgroundObject).append('<div class="background-option-current"><i class="fas fa-check-circle"></i></div>');
    N1.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

$(document).on('click', '#cancel-custom-background', function(e){
    e.preventDefault();

    N1.Phone.Animations.TopSlideUp(".background-custom", 200, -23);
});

// Profile Picture

var PressedProfilePicture = null;
var PressedProfilePictureObject = null;
var OldProfilePicture = null;
var ProfilePictureIsChecked = null;

$(document).on('click', '#accept-profilepicture', function(e){
    e.preventDefault();
    var ProfilePicture = N1.Phone.Data.MetaData.profilepicture;
    if (ProfilePicture === "default") {
        N1.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Standard avatar set!")
        N1.Phone.Animations.TopSlideUp(".settings-"+N1.Phone.Settings.OpenedTab+"-tab", 200, -100);
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="./img/default.png">');
    } else {
        N1.Phone.Notifications.Add("fas fa-paint-brush", "Settings", "Personal avatar set!")
        N1.Phone.Animations.TopSlideUp(".settings-"+N1.Phone.Settings.OpenedTab+"-tab", 200, -100);
        console.log(ProfilePicture)
        $("[data-settingstab='profilepicture']").find('.settings-tab-icon').html('<img src="'+ProfilePicture+'">');
    }
    $.post('http://N1-Phone /UpdateProfilePicture', JSON.stringify({
        profilepicture: ProfilePicture,
    }));
});

$(document).on('click', '#accept-custom-profilepicture', function(e){
    e.preventDefault();
    N1.Phone.Data.MetaData.profilepicture = $(".custom-profilepicture-input").val();
    $(OldProfilePicture).fadeOut(50, function(){
        $(OldProfilePicture).remove();
    });
    $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
    N1.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});

$(document).on('click', '.profilepicture-option', function(e){
    e.preventDefault();
    PressedProfilePicture = $(this).data('profilepicture');
    PressedProfilePictureObject = this;
    OldProfilePicture = $(this).parent().find('.profilepicture-option-current');
    ProfilePictureIsChecked = $(this).find('.profilepicture-option-current');
    if (ProfilePictureIsChecked.length === 0) {
        if (PressedProfilePicture != "custom-profilepicture") {
            N1.Phone.Data.MetaData.profilepicture = PressedProfilePicture
            $(OldProfilePicture).fadeOut(50, function(){
                $(OldProfilePicture).remove();
            });
            $(PressedProfilePictureObject).append('<div class="profilepicture-option-current"><i class="fas fa-check-circle"></i></div>');
        } else {
            N1.Phone.Animations.TopSlideDown(".profilepicture-custom", 200, 13);
        }
    }
});

$(document).on('click', '#cancel-profilepicture', function(e){
    e.preventDefault();
    N1.Phone.Animations.TopSlideUp(".settings-"+N1.Phone.Settings.OpenedTab+"-tab", 200, -100);
});


$(document).on('click', '#cancel-custom-profilepicture', function(e){
    e.preventDefault();
    N1.Phone.Animations.TopSlideUp(".profilepicture-custom", 200, -23);
});