N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Functions.CreateCallback('N1-scoreboard:server:GetActivity', function(source, cb)
    local PoliceCount = 0
    local AmbulanceCount = 0
    
    for k, v in pairs(N1Core.Functions.GetPlayers()) do
        local Player = N1Core.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                PoliceCount = PoliceCount + 1
            end

            if ((Player.PlayerData.job.name == "ambulance" or Player.PlayerData.job.name == "doctor") and Player.PlayerData.job.onduty) then
                AmbulanceCount = AmbulanceCount + 1
            end
        end
    end

    cb(PoliceCount, AmbulanceCount)
end)

N1Core.Functions.CreateCallback('N1-scoreboard:server:GetConfig', function(source, cb)
    cb(Config.IllegalActions)
end)

N1Core.Functions.CreateCallback('N1-scoreboard:server:GetPlayersArrays', function(source, cb)
    local players = {}
    for k, v in pairs(N1Core.Functions.GetPlayers()) do
        local Player = N1Core.Functions.GetPlayer(v)
        if Player ~= nil then 
            players[Player.PlayerData.source] = {}
            players[Player.PlayerData.source].permission = N1Core.Functions.IsOptin(Player.PlayerData.source)
        end
    end
    cb(players)
end)

RegisterServerEvent('N1-scoreboard:server:SetActivityBusy')
AddEventHandler('N1-scoreboard:server:SetActivityBusy', function(activity, bool)
    Config.IllegalActions[activity].busy = bool
    TriggerClientEvent('N1-scoreboard:client:SetActivityBusy', -1, activity, bool)
end)