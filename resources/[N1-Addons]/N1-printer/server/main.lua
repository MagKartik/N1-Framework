N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Functions.CreateUseableItem("printerdocument", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-printer:client:UseDocument', source, item)
end)