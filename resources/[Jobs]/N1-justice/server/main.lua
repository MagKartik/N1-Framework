N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

N1Core.Commands.Add("setlawyer", "Set someone as a lawyer", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = N1Core.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" then
        if OtherPlayer ~= nil then 
            local lawyerInfo = {
                id = math.random(100000, 999999),
                firstname = OtherPlayer.PlayerData.charinfo.firstname,
                lastname = OtherPlayer.PlayerData.charinfo.lastname,
                citizenid = OtherPlayer.PlayerData.citizenid,
            }
            OtherPlayer.Functions.SetJob("lawyer")
            OtherPlayer.Functions.AddItem("lawyerpass", 1, false, lawyerInfo)
            TriggerClientEvent("N1Core:Notify", source, "Je hebt " .. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. " Hired as a lawyer")
            TriggerClientEvent("N1Core:Notify", OtherPlayer.PlayerData.source, "You are now a lawyer")
            TriggerClientEvent('inventory:client:ItemBox', OtherPlayer.PlayerData.source, N1Core.Shared.Items["lawyerpass"], "add")
        else
            TriggerClientEvent("N1Core:Notify", source, "This person is not present..", "error")
        end
    else
        TriggerClientEvent("N1Core:Notify", source, "You have no rights..", "error")
    end
end)

N1Core.Commands.Add("removelawyer", "Delete someone from lawyer", {{name="id", help="Player ID"}}, true, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    local playerId = tonumber(args[1])
    local OtherPlayer = N1Core.Functions.GetPlayer(playerId)
    if Player.PlayerData.job.name == "judge" then
        if OtherPlayer ~= nil then 
            --OtherPlayer.Functions.SetJob("unemployed")
            TriggerClientEvent("N1Core:Notify", OtherPlayer.PlayerData.source, "You are now unemployed")
            TriggerClientEvent("N1Core:Notify", source, "Je hebt ".. OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname .. "Fired as a lawyer")
        else
            TriggerClientEvent("N1Core:Notify", source, "This person is not present..", "error")
        end
    else
        TriggerClientEvent("N1Core:Notify", source, "You have no rights..", "error")
    end
end)

N1Core.Functions.CreateUseableItem("lawyerpass", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.GetItemBySlot(item.slot) ~= nil then
        TriggerClientEvent("N1-justice:client:showLawyerLicense", -1, source, item.info)
    end
end)