N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

Citizen.CreateThread(function()
    Config.CurrentLab = math.random(1, #Config.Locations["laboratories"])
    print('Lab entry has been set to location: '..Config.CurrentLab)
end)

N1Core.Functions.CreateCallback('N1-methlab:server:GetData', function(source, cb)
    local LabData = {
        CurrentLab = Config.CurrentLab
    }
    cb(LabData)
end)

N1Core.Functions.CreateUseableItem("labkey", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    local LabKey = item.info.lab ~= nil and item.info.lab or 1

    TriggerClientEvent('N1-methlab:client:UseLabKey', source, LabKey)
end)

function GenerateRandomLab()
    local Lab = math.random(1, #Config.Locations["laboratories"])
    return Lab
end