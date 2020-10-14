N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local InstanceList = {}

RegisterServerEvent("instances:server:JoinInstance")
AddEventHandler('instances:server:JoinInstance', function(name, type)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if InstanceList ~= nil then 
        if (InstanceList[name] ~= nil) then
            InstanceList[name].players[src] = Player.PlayerData.citizenid
            TriggerClientEvent("instances:client:UpdateInstanceList", -1, name, InstanceList[name])
        else
            CreateNewInstance(name, type, src)
        end
    else
        CreateNewInstance(name, type, src)
    end
end)

RegisterServerEvent("instances:server:LeaveInstance")
AddEventHandler('instances:server:LeaveInstance', function(name)
    local src = source
    table.remove(InstanceList[name].players, src)
    TriggerClientEvent("instances:client:UpdateInstanceList", -1, name, InstanceList[name])
end)

function CreateNewInstance(name, type, source)
    local Player = N1Core.Functions.GetPlayer(source)
    InstanceList[name] = {
        name = name,
        type = type,
        owner = source,
        players = {
            [source] = Player.PlayerData.citizenid,
        }
    }
    TriggerClientEvent("instances:client:UpdateInstanceList", -1, name, InstanceList[name])
end

N1Core.Functions.CreateCallback('instance:GetOwnerList', function(source, cb, type)
    local src = source
    local ownerList = {}
    if (InstanceList ~= nil) then
        for name, v in pairs(InstanceList) do 
            if InstanceList[name].type == type then
                table.insert(ownerList, InstanceList[name].owner)
            end
        end
    end

    cb(ownerList)
end)