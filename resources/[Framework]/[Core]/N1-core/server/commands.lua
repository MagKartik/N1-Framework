N1Core.Commands = {}
N1Core.Commands.List = {}

N1Core.Commands.Add = function(name, help, arguments, argsrequired, callback, permission) -- [name] = command name (ex. /givemoney), [help] = help text, [arguments] = arguments that need to be passed (ex. {{name="id", help="ID of a player"}, {name="amount", help="amount of money"}}), [argsrequired] = set arguments required (true or false), [callback] = function(source, args) callback, [permission] = rank or job of a player
	N1Core.Commands.List[name:lower()] = {
		name = name:lower(),
		permission = permission ~= nil and permission:lower() or "user",
		help = help,
		arguments = arguments,
		argsrequired = argsrequired,
		callback = callback,
	}
end

N1Core.Commands.Refresh = function(source)
	local Player = N1Core.Functions.GetPlayer(tonumber(source))
	if Player ~= nil then
		for command, info in pairs(N1Core.Commands.List) do
			if N1Core.Functions.HasPermission(source, "god") or N1Core.Functions.HasPermission(source, N1Core.Commands.List[command].permission) then
				TriggerClientEvent('chat:addSuggestion', source, "/"..command, info.help, info.arguments)
			end
		end
	end
end

N1Core.Commands.Add("tp", "Teleport to a player or location", {{name="id/x", help="ID of player or X position"}, {name="y", help="Y position"}, {name="z", help="Z position"}}, false, function(source, args)
	if (args[1] ~= nil and (args[2] == nil and args[3] == nil)) then
		-- tp to player
		local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
		if Player ~= nil then
			TriggerClientEvent('N1Core:Command:TeleportToPlayer', source, Player.PlayerData.source)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
		end
	else
		-- tp to location
		if args[1] ~= nil and args[2] ~= nil and args[3] ~= nil then
			local x = tonumber(args[1])
			local y = tonumber(args[2])
			local z = tonumber(args[3])
			TriggerClientEvent('N1Core:Command:TeleportToCoords', source, x, y, z)
		else
			TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Not every argument has been entered (x, y, z)")
		end
	end
end, "admin")

N1Core.Commands.Add("addpermission", "Grant permissions to someone (god/admin)", {{name="id", help="ID of player"}, {name="permission", help="Permission level"}}, true, function(source, args)
	local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
	local permission = tostring(args[2]):lower()
	if Player ~= nil then
		N1Core.Functions.AddPermission(Player.PlayerData.source, permission)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")	
	end
end, "god")

N1Core.Commands.Add("removepermission", "Remove permissions from someone", {{name="id", help="ID of player"}}, true, function(source, args)
	local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		N1Core.Functions.RemovePermission(Player.PlayerData.source)
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")	
	end
end, "god")

N1Core.Commands.Add("car", "Spawn a vehicle", {{name="model", help="Model name of the vehicle"}}, true, function(source, args)
	TriggerClientEvent('N1Core:Command:SpawnVehicle', source, args[1])
end, "admin")

N1Core.Commands.Add("debug", "Turn debug mode on / off", {}, false, function(source, args)
	TriggerClientEvent('koil-debug:toggle', source)
end, "admin")

N1Core.Commands.Add("dv", "Despawn a vehicle", {}, false, function(source, args)
	TriggerClientEvent('N1Core:Command:DeleteVehicle', source)
end, "admin")

N1Core.Commands.Add("tpm", "Teleport to your waypoint", {}, false, function(source, args)
	TriggerClientEvent('N1Core:Command:GoToMarker', source)
end, "admin")

N1Core.Commands.Add("givemoney", "Give money to a player", {{name="id", help="Player ID"},{name="moneytype", help="Type of money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.AddMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

N1Core.Commands.Add("setmoney", "set a players money amount", {{name="id", help="Player ID"},{name="moneytype", help="Type of money (cash, bank, crypto)"}, {name="amount", help="Amount of money"}}, true, function(source, args)
	local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetMoney(tostring(args[2]), tonumber(args[3]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

N1Core.Commands.Add("setjob", "Assign a job to a player", {{name="id", help="Player ID"}, {name="job", help="Job name"}}, true, function(source, args)
	local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetJob(tostring(args[2]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

N1Core.Commands.Add("job", "See what job you have", {}, false, function(source, args)
	local Player = N1Core.Functions.GetPlayer(source)
	TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Job: "..Player.PlayerData.job.label)
end)

N1Core.Commands.Add("setgang", "Assign a player to a gang", {{name="id", help="Player ID"}, {name="job", help="Name of a gang"}}, true, function(source, args)
	local Player = N1Core.Functions.GetPlayer(tonumber(args[1]))
	if Player ~= nil then
		Player.Functions.SetGang(tostring(args[2]))
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

N1Core.Commands.Add("gang", "See what gang you're in", {}, false, function(source, args)
	local Player = N1Core.Functions.GetPlayer(source)

	if Player.PlayerData.gang.name ~= "geen" then
		TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "Gang: "..Player.PlayerData.gang.label)
	else
		TriggerClientEvent('N1Core:Notify', source, "You're not in a gang!", "error")
	end
end)

N1Core.Commands.Add("testnotify", "test notify", {{name="text", help="Tekst enzo"}}, true, function(source, args)
	TriggerClientEvent('N1Core:Notify', source, table.concat(args, " "), "success")
end, "god")

N1Core.Commands.Add("clearinv", "Clear the inventory of a player", {{name="id", help="Player ID"}}, false, function(source, args)
	local playerId = args[1] ~= nil and args[1] or source 
	local Player = N1Core.Functions.GetPlayer(tonumber(playerId))
	if Player ~= nil then
		Player.Functions.ClearInventory()
	else
		TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "Player is not online!")
	end
end, "admin")

N1Core.Commands.Add("ooc", "Out of Character message", {}, false, function(source, args)
	local message = table.concat(args, " ")
	TriggerClientEvent("N1Core:Client:LocalOutOfCharacter", -1, source, GetPlayerName(source), message)
	local Players = N1Core.Functions.GetPlayers()
	local Player = N1Core.Functions.GetPlayer(source)

	for k, v in pairs(N1Core.Functions.GetPlayers()) do
		if N1Core.Functions.HasPermission(v, "admin") then
			if N1Core.Functions.IsOptin(v) then
				TriggerClientEvent('chatMessage', v, "OOC " .. GetPlayerName(source), "normal", message)
				TriggerEvent("N1-log:server:CreateLog", "ooc", "OOC", "white", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Message:** " ..message, false)
			end
		end
	end
end)