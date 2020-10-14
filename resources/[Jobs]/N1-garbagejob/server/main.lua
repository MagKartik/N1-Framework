N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local Bail = {}

N1Core.Functions.CreateCallback('N1-garbagejob:server:HasMoney', function(source, cb)
    local Player = N1Core.Functions.GetPlayer(source)
    local CitizenId = Player.PlayerData.citizenid

    if Player.PlayerData.money.cash >= Config.BailPrice then
        Bail[CitizenId] = "cash"
        Player.Functions.RemoveMoney('cash', Config.BailPrice)
        cb(true)
    elseif Player.PlayerData.money.bank >= Config.BailPrice then
        Bail[CitizenId] = "bank"
        Player.Functions.RemoveMoney('bank', Config.BailPrice)
        cb(true)
    else
        cb(false)
    end
end)

N1Core.Functions.CreateCallback('N1-garbagejob:server:CheckBail', function(source, cb)
    local Player = N1Core.Functions.GetPlayer(source)
    local CitizenId = Player.PlayerData.citizenid

    if Bail[CitizenId] ~= nil then
        Player.Functions.AddMoney(Bail[CitizenId], Config.BailPrice)
        Bail[CitizenId] = nil
        cb(true)
    else
        cb(false)
    end
end)

local Materials = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

RegisterServerEvent('N1-garbagejob:server:PayShit')
AddEventHandler('N1-garbagejob:server:PayShit', function(amount, location)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if amount > 0 then
        Player.Functions.AddMoney('bank', amount)

        if location == #Config.Locations["vuilnisbakken"] then
            for i = 1, math.random(3, 5), 1 do
                local item = Materials[math.random(1, #Materials)]
                Player.Functions.AddItem(item, math.random(40, 70))
                TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[item], 'add')
                Citizen.Wait(500)
            end
        end

        TriggerClientEvent('N1Core:Notify', src, "You got paid ₹"..amount..",- from the bank", "success")
    else
        TriggerClientEvent('N1Core:Notify', src, "You got paid nothing..", "error")
    end
end)