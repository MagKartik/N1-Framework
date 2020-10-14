N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Commands.Add("shuff", "Switch from seats", {}, false, function(source, args)
    TriggerClientEvent('N1-seatshuff:client:Shuff', source)
end)