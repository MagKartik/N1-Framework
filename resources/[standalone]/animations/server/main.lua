N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

N1Core.Commands.Add("am", "Toggle animation menu", {}, false, function(source, args)
	TriggerClientEvent('animations:client:ToggleMenu', source)
end)

N1Core.Commands.Add("a", "Do an animation, for the animation list do /am", {{name = "name", help = "Emote name"}}, true, function(source, args)
	TriggerClientEvent('animations:client:EmoteCommandStart', source, args)
end)

N1Core.Functions.CreateUseableItem("walkstick", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("animations:UseWandelStok", source)
end)
