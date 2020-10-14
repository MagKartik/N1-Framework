N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

N1Core.Commands.Add("me", "Character interactions", {}, false, function(source, args)
	local text = table.concat(args, ' ')
	local Player = N1Core.Functions.GetPlayer(source)
	TriggerClientEvent('3dme:triggerDisplay', -1, text, source)
    TriggerEvent("N1-log:server:CreateLog", "me", "Me", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..")** " ..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname.. " **" ..text, false)
end)