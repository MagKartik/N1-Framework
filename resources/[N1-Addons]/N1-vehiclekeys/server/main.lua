N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local VehicleList = {}

N1Core.Functions.CreateCallback('vehiclekeys:CheckHasKey', function(source, cb, plate)
    local Player = N1Core.Functions.GetPlayer(source)
    cb(CheckOwner(plate, Player.PlayerData.citizenid))
end)

RegisterServerEvent('vehiclekeys:server:SetVehicleOwner')
AddEventHandler('vehiclekeys:server:SetVehicleOwner', function(plate)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if VehicleList ~= nil then
        if DoesPlateExist(plate) then
            for k, val in pairs(VehicleList) do
                if val.plate == plate then
                    table.insert(VehicleList[k].owners, Player.PlayerData.citizenid)
                end
            end
        else
            local vehicleId = #VehicleList+1
            VehicleList[vehicleId] = {
                plate = plate, 
                owners = {},
            }
            VehicleList[vehicleId].owners[1] = Player.PlayerData.citizenid
        end
    else
        local vehicleId = #VehicleList+1
        VehicleList[vehicleId] = {
            plate = plate, 
            owners = {},
        }
        VehicleList[vehicleId].owners[1] = Player.PlayerData.citizenid
    end
end)

RegisterServerEvent('vehiclekeys:server:GiveVehicleKeys')
AddEventHandler('vehiclekeys:server:GiveVehicleKeys', function(plate, target)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if CheckOwner(plate, Player.PlayerData.citizenid) then
        if N1Core.Functions.GetPlayer(target) ~= nil then
            TriggerClientEvent('vehiclekeys:client:SetOwner', target, plate)
            TriggerClientEvent('N1Core:Notify', src, "You gave the keys!")
            TriggerClientEvent('N1Core:Notify', target, "You got the keys!")
        else
            TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "Player not online!")
        end
    else
        TriggerClientEvent('chatMessage', src, "SYSTEM", "error", "You dont have the keys of the vehicle!")
    end
end)

N1Core.Commands.Add("motor", "Toggle engine On/Off of the vehicle", {}, false, function(source, args)
	TriggerClientEvent('vehiclekeys:client:ToggleEngine', source)
end)

N1Core.Commands.Add("geefsleutels", "Give keys of the vehicle", {{name = "id", help = "Speler id"}}, true, function(source, args)
	local src = source
    local target = tonumber(args[1])
    TriggerClientEvent('vehiclekeys:client:GiveKeys', src, target)
end)

function DoesPlateExist(plate)
    if VehicleList ~= nil then
        for k, val in pairs(VehicleList) do
            if val.plate == plate then
                return true
            end
        end
    end
    return false
end

function CheckOwner(plate, identifier)
    local retval = false
    if VehicleList ~= nil then
        for k, val in pairs(VehicleList) do
            if val.plate == plate then
                for key, owner in pairs(VehicleList[k].owners) do
                    if owner == identifier then
                        retval = true
                    end
                end
            end
        end
    end
    return retval
end

N1Core.Functions.CreateUseableItem("lockpick", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("lockpicks:UseLockpick", source, false)
end)

N1Core.Functions.CreateUseableItem("advancedlockpick", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("lockpicks:UseLockpick", source, true)
end)