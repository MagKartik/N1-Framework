N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local PaymentTax = 15
local Bail = {}

RegisterServerEvent('N1-tow:server:DoBail')
AddEventHandler('N1-tow:server:DoBail', function(bool, vehInfo)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if bool then
        if Player.PlayerData.money.cash >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('cash', Config.BailPrice, "tow-paid-bail")
            TriggerClientEvent('N1Core:Notify', src, 'You paid your deposit of 1000,- ', 'success')
            TriggerClientEvent('N1-tow:client:SpawnVehicle', src, vehInfo)
        elseif Player.PlayerData.money.bank >= Config.BailPrice then
            Bail[Player.PlayerData.citizenid] = Config.BailPrice
            Player.Functions.RemoveMoney('bank', Config.BailPrice, "tow-paid-bail")
            TriggerClientEvent('N1Core:Notify', src, 'You paid your deposit of 1000,-', 'success')
            TriggerClientEvent('N1-tow:client:SpawnVehicle', src, vehInfo)
        else
            TriggerClientEvent('N1Core:Notify', src, 'You dont have enough cash, the deposit is 1000,-', 'error')
        end
    else
        if Bail[Player.PlayerData.citizenid] ~= nil then
            Player.Functions.AddMoney('cash', Bail[Player.PlayerData.citizenid], "tow-bail-paid")
            Bail[Player.PlayerData.citizenid] = nil
            TriggerClientEvent('N1Core:Notify', src, 'You have received your deporit of 1000,- back', 'success')
        end
    end
end)

RegisterNetEvent('N1-tow:server:11101110')
AddEventHandler('N1-tow:server:11101110', function(drops)
    local src = source 
    local Player = N1Core.Functions.GetPlayer(src)
    local drops = tonumber(drops)
    local bonus = 0
    local DropPrice = math.random(450, 700)
    if drops > 5 then 
        bonus = math.ceil((DropPrice / 100) * 5)
    elseif drops > 10 then
        bonus = math.ceil((DropPrice / 100) * 7)
    elseif drops > 15 then
        bonus = math.ceil((DropPrice / 100) * 10)
    elseif drops > 20 then
        bonus = math.ceil((DropPrice / 100) * 12)
    end
    local price = (DropPrice * drops) + bonus
    local taxAmount = math.ceil((price / 100) * PaymentTax)
    local payment = price - taxAmount

    Player.Functions.AddJobReputation(1)
    Player.Functions.AddMoney("bank", payment, "tow-salary")
    TriggerClientEvent('chatMessage', source, "BAAN", "warning", "You received your salary from: ₹"..payment..", gross: ₹"..price.." (waarvan ₹"..bonus.." bonus) en ₹"..taxAmount.." tax ("..PaymentTax.."%)")
end)

N1Core.Commands.Add("npc", "Toggle npc job option", {}, false, function(source, args)
	TriggerClientEvent("jobs:client:ToggleNpc", source)
end)

N1Core.Commands.Add("tow", "Place the car on the back of the towtruck", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "tow" then
        TriggerClientEvent("N1-tow:client:TowVehicle", source)
    end
end)

