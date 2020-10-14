N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Functions.CreateUseableItem("fitbit", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-fitbit:use', source)
  end)

RegisterServerEvent('N1-fitbit:server:setValue')
AddEventHandler('N1-fitbit:server:setValue', function(type, value)
    local src = source
    local ply = N1Core.Functions.GetPlayer(src)
    local fitbitData = {}

    if type == "thirst" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = value,
            food = currentMeta.food
        }
    elseif type == "food" then
        local currentMeta = ply.PlayerData.metadata["fitbit"]
        fitbitData = {
            thirst = currentMeta.thirst,
            food = value
        }
    end

    ply.Functions.SetMetaData('fitbit', fitbitData)
end)

N1Core.Functions.CreateCallback('N1-fitbit:server:HasFitbit', function(source, cb)
    local Ply = N1Core.Functions.GetPlayer(source)
    local Fitbit = Ply.Functions.GetItemByName("fitbit")

    if Fitbit ~= nil then
        cb(true)
    else
        cb(false)
    end
end)