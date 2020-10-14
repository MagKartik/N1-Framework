N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

local trunkBusy = {}

RegisterServerEvent('N1-trunk:server:setTrunkBusy')
AddEventHandler('N1-trunk:server:setTrunkBusy', function(plate, busy)
    trunkBusy[plate] = busy
end)

N1Core.Functions.CreateCallback('N1-trunk:server:getTrunkBusy', function(source, cb, plate)
    if trunkBusy[plate] then
        cb(true)
    end
    cb(false)
end)

RegisterServerEvent('N1-trunk:server:KidnapTrunk')
AddEventHandler('N1-trunk:server:KidnapTrunk', function(targetId, closestVehicle)
    TriggerClientEvent('N1-trunk:client:KidnapGetIn', targetId, closestVehicle)
end)

N1Core.Commands.Add("getintrunk", "Get in trunk", {}, false, function(source, args)
    TriggerClientEvent('N1-trunk:client:GetIn', source)
end)

N1Core.Commands.Add("kidnaptrunk", "Get in trunk", {}, false, function(source, args)
    TriggerClientEvent('N1-trunk:server:KidnapTrunk', source)
end)