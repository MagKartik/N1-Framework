N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

RegisterServerEvent('N1-diving:server:SetBerthVehicle')
AddEventHandler('N1-diving:server:SetBerthVehicle', function(BerthId, vehicleModel)
    TriggerClientEvent('N1-diving:client:SetBerthVehicle', -1, BerthId, vehicleModel)
    
    N1Boatshop.Locations["berths"][BerthId]["boatModel"] = boatModel
end)

RegisterServerEvent('N1-diving:server:SetDockInUse')
AddEventHandler('N1-diving:server:SetDockInUse', function(BerthId, InUse)
    N1Boatshop.Locations["berths"][BerthId]["inUse"] = InUse
    TriggerClientEvent('N1-diving:client:SetDockInUse', -1, BerthId, InUse)
end)

N1Core.Functions.CreateCallback('N1-diving:server:GetBusyDocks', function(source, cb)
    cb(N1Boatshop.Locations["berths"])
end)

RegisterServerEvent('N1-diving:server:BuyBoat')
AddEventHandler('N1-diving:server:BuyBoat', function(boatModel, BerthId)
    local BoatPrice = N1Boatshop.ShopBoats[boatModel]["price"]
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local PlayerMoney = {
        cash = Player.PlayerData.money.cash,
        bank = Player.PlayerData.money.bank,
    }
    local missingMoney = 0
    local plate = "LUAL"..math.random(1111, 9999)

    if PlayerMoney.cash >= BoatPrice then
        Player.Functions.RemoveMoney('cash', BoatPrice, "bought-boat")
        TriggerClientEvent('N1-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    elseif PlayerMoney.bank >= BoatPrice then
        Player.Functions.RemoveMoney('bank', BoatPrice, "bought-boat")
        TriggerClientEvent('N1-diving:client:BuyBoat', src, boatModel, plate)
        InsertBoat(boatModel, Player, plate)
    else
        if PlayerMoney.bank > PlayerMoney.cash then
            missingMoney = (BoatPrice - PlayerMoney.bank)
        else
            missingMoney = (BoatPrice - PlayerMoney.cash)
        end
        TriggerClientEvent('N1Core:Notify', src, 'You don\'t have enough money, you are missing ₹'..missingMoney, 'error', 4000)
    end
end)

function InsertBoat(boatModel, Player, plate)
    N1Core.Functions.ExecuteSql(false, "INSERT INTO `player_boats` (`citizenid`, `model`, `plate`) VALUES ('"..Player.PlayerData.citizenid.."', '"..boatModel.."', '"..plate.."')")
end

N1Core.Functions.CreateUseableItem("jerry_can", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)

    TriggerClientEvent("N1-diving:client:UseJerrycan", source)
end)

N1Core.Functions.CreateUseableItem("diving_gear", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)

    TriggerClientEvent("N1-diving:client:UseGear", source, true)
end)

RegisterServerEvent('N1-diving:server:RemoveItem')
AddEventHandler('N1-diving:server:RemoveItem', function(item, amount)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    Player.Functions.RemoveItem(item, amount)
end)

N1Core.Functions.CreateCallback('N1-diving:server:GetMyBoats', function(source, cb, dock)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_boats` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `boathouse` = '"..dock.."'", function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

N1Core.Functions.CreateCallback('N1-diving:server:GetDepotBoats', function(source, cb, dock)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_boats` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `state` = '0'", function(result)
        if result[1] ~= nil then
            cb(result)
        else
            cb(nil)
        end
    end)
end)

RegisterServerEvent('N1-diving:server:SetBoatState')
AddEventHandler('N1-diving:server:SetBoatState', function(plate, state, boathouse)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_boats` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            N1Core.Functions.ExecuteSql(false, "UPDATE `player_boats` SET `state` = '"..state.."' WHERE `plate` = '"..plate.."' AND `citizenid` = '"..Player.PlayerData.citizenid.."'")
    
            if state == 1 then
                N1Core.Functions.ExecuteSql(false, "UPDATE `player_boats` SET `boathouse` = '"..boathouse.."' WHERE `plate` = '"..plate.."' AND `citizenid` = '"..Player.PlayerData.citizenid.."'")
            end
        end
    end)
end)

RegisterServerEvent('N1-diving:server:CallCops')
AddEventHandler('N1-diving:server:CallCops', function(Coords)
    local src = source
    for k, v in pairs(N1Core.Functions.GetPlayers()) do
        local Player = N1Core.Functions.GetPlayer(v)
        if Player ~= nil then
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                local msg = "someone is stealing coral!"
                TriggerClientEvent('N1-diving:client:CallCops', Player.PlayerData.source, Coords, msg)
                local alertData = {
                    title = "Illegal diving",
                    coords = {x = Coords.x, y = Coords.y, z = Coords.z},
                    description = msg,
                }
                TriggerClientEvent("N1-phone:client:addPoliceAlert", -1, alertData)
            end
        end
	end
end)

local AvailableCoral = {}

N1Core.Commands.Add("wetsuit", "Pull your wetsuit off", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("N1-diving:client:UseGear", source, false)
end)

RegisterServerEvent('N1-diving:server:SellCoral')
AddEventHandler('N1-diving:server:SellCoral', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if HasCoral(src) then
        for k, v in pairs(AvailableCoral) do
            local Item = Player.Functions.GetItemByName(v.item)
            local price = (Item.amount * v.price)
            local Reward = math.ceil(GetItemPrice(Item, price))

            if Item.amount > 1 then
                for i = 1, Item.amount, 1 do
                    Player.Functions.RemoveItem(Item.name, 1)
                    TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[Item.name], "remove")
                    Player.Functions.AddMoney('cash', math.ceil((Reward / Item.amount)), "sold-coral")
                    Citizen.Wait(250)
                end
            else
                Player.Functions.RemoveItem(Item.name, 1)
                Player.Functions.AddMoney('cash', Reward, "sold-coral")
                TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[Item.name], "remove")
            end
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'You don\'t have any coral to sell..', 'error')
    end
end)

function GetItemPrice(Item, price)
    if Item.amount > 5 then
        price = price / 100 * 80
    elseif Item.amount > 10 then
        price = price / 100 * 70
    elseif Item.amount > 15 then
        price = price / 100 * 50
    end
    return price
end

function HasCoral(src)
    local Player = N1Core.Functions.GetPlayer(src)
    local retval = false
    AvailableCoral = {}

    for k, v in pairs(N1Diving.CoralTypes) do
        local Item = Player.Functions.GetItemByName(v.item)
        if Item ~= nil then
            table.insert(AvailableCoral, v)
            retval = true
        end
    end
    return retval
end