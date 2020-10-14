N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

N1Core.Commands.Add("newscam", "Take news camera", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "reporter" then
        TriggerClientEvent("Cam:ToggleCam", source)
    end
end)

N1Core.Commands.Add("newsmic", "Take news microphone", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "reporter" then
        TriggerClientEvent("Mic:ToggleMic", source)
    end
end)

