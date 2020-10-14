N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

RegisterServerEvent('N1-customs:server:UpdateBusyState')
AddEventHandler('N1-customs:server:UpdateBusyState', function(k, bool)
    N1Customs.Locations[k]["busy"] = bool
    TriggerClientEvent('N1-customs:client:UpdateBusyState', -1, k, bool)
end)

RegisterServerEvent('N1-customs:print')
AddEventHandler('N1-customs:print', function(data)
    print(data)
end)

N1Core.Functions.CreateCallback('N1-customs:server:CanPurchase', function(source, cb, price)
    local Player = N1Core.Functions.GetPlayer(source)
    local CanBuy = false

    if Player.PlayerData.money.cash >= price then
        Player.Functions.RemoveMoney('cash', price)
        CanBuy = true
    elseif Player.PlayerData.money.bank >= price then
        Player.Functions.RemoveMoney('bank', price)
        CanBuy = true
    else
        CanBuy = false
    end

    cb(CanBuy)
end)

RegisterServerEvent("N1-customs:server:SaveVehicleProps")
AddEventHandler("N1-customs:server:SaveVehicleProps", function(vehicleProps)
	local src = source
    if IsVehicleOwned(vehicleProps.plate) then
        N1Core.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `mods` = '"..json.encode(vehicleProps).."' WHERE `plate` = '"..vehicleProps.plate.."'")
    end
end)


function IsVehicleOwned(plate)
    local retval = false
    N1Core.Functions.ExecuteSql(true, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] ~= nil then
            retval = true
        end
    end)
    return retval
end