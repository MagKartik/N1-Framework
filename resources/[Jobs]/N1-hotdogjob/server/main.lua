N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

local Bail = {}

N1Core.Functions.CreateCallback('N1-hotdogjob:server:HasMoney', function(source, cb)
    local Player = N1Core.Functions.GetPlayer(source)

    if Player.PlayerData.money.cash >= Config.Bail then
        Player.Functions.RemoveMoney('cash', Config.Bail)
        Bail[Player.PlayerData.citizenid] = true
        cb(true)
    elseif Player.PlayerData.money.bank >= Config.Bail then
        Player.Functions.RemoveMoney('bank', Config.Bail)
        Bail[Player.PlayerData.citizenid] = true
        cb(true)
    else
        Bail[Player.PlayerData.citizenid] = false
        cb(false)
    end
end)

N1Core.Functions.CreateCallback('N1-hotdogjob:server:BringBack', function(source, cb)
    local Player = N1Core.Functions.GetPlayer(source)

    if Bail[Player.PlayerData.citizenid] then
        Player.Functions.AddMoney('cash', Config.Bail)
        cb(true)
    else
        cb(false)
    end
end)

RegisterServerEvent('N1-hotdogjob:server:Sell')
AddEventHandler('N1-hotdogjob:server:Sell', function(Amount, Price)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    Player.Functions.AddMoney('cash', tonumber(Amount * Price))
end)

local Reset = false

RegisterServerEvent('N1-hotdogjob:server:UpdateReputation')
AddEventHandler('N1-hotdogjob:server:UpdateReputation', function(quality)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local JobReputation = Player.PlayerData.metadata["jobrep"]
    
    if Reset then
        JobReputation["hotdog"] = 0
        Player.Functions.SetMetaData("jobrep", JobReputation)
        TriggerClientEvent('N1-hotdogjob:client:UpdateReputation', src, JobReputation)
        return
    end

    if quality == "exotic" then
        if JobReputation["hotdog"] ~= nil and JobReputation["hotdog"] + 3 > Config.MaxReputation then
            JobReputation["hotdog"] = Config.MaxReputation
            Player.Functions.SetMetaData("jobrep", JobReputation)
            TriggerClientEvent('N1-hotdogjob:client:UpdateReputation', src, JobReputation)
            return
        end
        if JobReputation["hotdog"] == nil then
            JobReputation["hotdog"] = 3
        else
            JobReputation["hotdog"] = JobReputation["hotdog"] + 3
        end
    elseif quality == "rare" then
        if JobReputation["hotdog"] ~= nil and JobReputation["hotdog"] + 2 > Config.MaxReputation then
            JobReputation["hotdog"] = Config.MaxReputation
            Player.Functions.SetMetaData("jobrep", JobReputation)
            TriggerClientEvent('N1-hotdogjob:client:UpdateReputation', src, JobReputation)
            return
        end
        if JobReputation["hotdog"] == nil then
            JobReputation["hotdog"] = 2
        else
            JobReputation["hotdog"] = JobReputation["hotdog"] + 2
        end
    elseif quality == "common" then
        if JobReputation["hotdog"] ~= nil and JobReputation["hotdog"] + 1 > Config.MaxReputation then
            JobReputation["hotdog"] = Config.MaxReputation
            Player.Functions.SetMetaData("jobrep", JobReputation)
            TriggerClientEvent('N1-hotdogjob:client:UpdateReputation', src, JobReputation)
            return
        end
        if JobReputation["hotdog"] == nil then
            JobReputation["hotdog"] = 1
        else
            JobReputation["hotdog"] = JobReputation["hotdog"] + 1
        end
    end
    Player.Functions.SetMetaData("jobrep", JobReputation)
    TriggerClientEvent('N1-hotdogjob:client:UpdateReputation', src, JobReputation)
end)


N1Core.Commands.Add("removestand", "", {}, false, function(source, args)
    TriggerClientEvent('N1-hotdogjob:staff:DeletStand', source)
end, 'admin')