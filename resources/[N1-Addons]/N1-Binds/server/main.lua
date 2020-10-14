N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Commands.Add("binds", "Open commandbinding menu", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
	TriggerClientEvent("N1-commandbinding:client:openUI", source)
end)

RegisterServerEvent('N1-commandbinding:server:setKeyMeta')
AddEventHandler('N1-commandbinding:server:setKeyMeta', function(keyMeta)
    local src = source
    local ply = N1Core.Functions.GetPlayer(src)

    ply.Functions.SetMetaData("commandbinds", keyMeta)
end)