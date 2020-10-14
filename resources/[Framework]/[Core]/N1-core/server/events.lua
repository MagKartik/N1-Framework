-- Player joined
RegisterServerEvent("N1Core:PlayerJoined")
AddEventHandler('N1Core:PlayerJoined', function()
	local src = source
end)

AddEventHandler('playerDropped', function(reason) 
	local src = source
	print("Dropped: "..GetPlayerName(src))
	TriggerEvent("N1-log:server:CreateLog", "joinleave", "Dropped", "red", "**".. GetPlayerName(src) .. "** ("..GetPlayerIdentifiers(src)[1]..") left..")
	TriggerEvent("N1-log:server:sendLog", GetPlayerIdentifiers(src)[1], "joined", {})
	if reason ~= "Reconnecting" and src > 60000 then return false end
	if(src==nil or (N1Core.Players[src] == nil)) then return false end
	N1Core.Players[src].Functions.Save()
	N1Core.Players[src] = nil
end)

-- Checking everything before joining
AddEventHandler('playerConnecting', function(playerName, setKickReason, deferrals)
	deferrals.defer()
	local src = source
	deferrals.update("\nChecking name...")
	local name = GetPlayerName(src)
	if name == nil then 
		N1Core.Functions.Kick(src, 'Please don\'t use a blank Steam username.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	if(string.match(name, "[*%%'=`\"]")) then
        N1Core.Functions.Kick(src, 'You have a character in your username ('..string.match(name, "[*%%'=`\"]")..') that is not allowed.\nPlease remove this out of your Steam username.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	if (string.match(name, "drop") or string.match(name, "table") or string.match(name, "database")) then
        N1Core.Functions.Kick(src, 'Your username contains a word (drop/table/database) that is not allowed.\nPlease change your Steam username.', setKickReason, deferrals)
        CancelEvent()
        return false
	end
	deferrals.update("\nChecking identifiers...")
    local identifiers = GetPlayerIdentifiers(src)
	local steamid = identifiers[1]
	local license = identifiers[2]
    if (N1Config.IdentifierType == "steam" and (steamid:sub(1,6) == "steam:") == false) then
        N1Core.Functions.Kick(src, 'You need to open Steam to play.', setKickReason, deferrals)
        CancelEvent()
		return false
	elseif (N1Config.IdentifierType == "license" and (steamid:sub(1,6) == "license:") == false) then
		N1Core.Functions.Kick(src, 'No Social Club license found.', setKickReason, deferrals)
        CancelEvent()
		return false
    end
	deferrals.update("\nChecking ban status...")
    local isBanned, Reason = N1Core.Functions.IsPlayerBanned(src)
    if(isBanned) then
        N1Core.Functions.Kick(src, Reason, setKickReason, deferrals)
        CancelEvent()
        return false
    end
	deferrals.update("\nChecking whitelist status...")
    if(not N1Core.Functions.IsWhitelisted(src)) then
        N1Core.Functions.Kick(src, 'You aren\'t whitelisted.', setKickReason, deferrals)
        CancelEvent()
        return false
    end
	deferrals.update("\nChecking server status...")
    if(N1Core.Config.Server.closed and not IsPlayerAceAllowed(src, "N1admin.join")) then
		N1Core.Functions.Kick(_source, 'the server is closed:\n'..N1Core.Config.Server.closedReason, setKickReason, deferrals)
        CancelEvent()
        return false
	end
	TriggerEvent("N1-log:server:CreateLog", "joinleave", "Queue", "orange", "**"..name .. "** ("..json.encode(GetPlayerIdentifiers(src))..") in queue..")
	TriggerEvent("N1-log:server:sendLog", GetPlayerIdentifiers(src)[1], "left", {})
	TriggerEvent("connectqueue:playerConnect", src, setKickReason, deferrals)
end)

RegisterServerEvent("N1Core:server:CloseServer")
AddEventHandler('N1Core:server:CloseServer', function(reason)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if N1Core.Functions.HasPermission(source, "admin") or N1Core.Functions.HasPermission(source, "god") then 
        local reason = reason ~= nil and reason or "No reason specified..."
        N1Core.Config.Server.closed = true
        N1Core.Config.Server.closedReason = reason
        TriggerClientEvent("N1admin:client:SetServerStatus", -1, true)
	else
		N1Core.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterServerEvent("N1Core:server:OpenServer")
AddEventHandler('N1Core:server:OpenServer', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if N1Core.Functions.HasPermission(source, "admin") or N1Core.Functions.HasPermission(source, "god") then
        N1Core.Config.Server.closed = false
        TriggerClientEvent("N1admin:client:SetServerStatus", -1, false)
    else
        N1Core.Functions.Kick(src, "You don't have permissions for this..", nil, nil)
    end
end)

RegisterServerEvent("N1Core:UpdatePlayer")
AddEventHandler('N1Core:UpdatePlayer', function(data)
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	
	if Player ~= nil then
		Player.PlayerData.position = data.position

		local newHunger = Player.PlayerData.metadata["hunger"] - 4.2
		local newThirst = Player.PlayerData.metadata["thirst"] - 3.8
		if newHunger <= 0 then newHunger = 0 end
		if newThirst <= 0 then newThirst = 0 end
		Player.Functions.SetMetaData("thirst", newThirst)
		Player.Functions.SetMetaData("hunger", newHunger)

		Player.Functions.AddMoney("bank", Player.PlayerData.job.payment)
		TriggerClientEvent('N1Core:Notify', src, "You received your paycheck of ₹"..Player.PlayerData.job.payment)
		TriggerClientEvent("hud:client:UpdateNeeds", src, newHunger, newThirst)

		Player.Functions.Save()
	end
end)

RegisterServerEvent("N1Core:UpdatePlayerPosition")
AddEventHandler("N1Core:UpdatePlayerPosition", function(position)
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	if Player ~= nil then
		Player.PlayerData.position = position
	end
end)

RegisterServerEvent("N1Core:Server:TriggerCallback")
AddEventHandler('N1Core:Server:TriggerCallback', function(name, ...)
	local src = source
	N1Core.Functions.TriggerCallback(name, src, function(...)
		TriggerClientEvent("N1Core:Client:TriggerCallback", src, name, ...)
	end, ...)
end)

RegisterServerEvent("N1Core:Server:UseItem")
AddEventHandler('N1Core:Server:UseItem', function(item)
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	if item ~= nil and item.amount > 0 then
		if N1Core.Functions.CanUseItem(item.name) then
			N1Core.Functions.UseItem(src, item)
		end
	end
end)

RegisterServerEvent("N1Core:Server:RemoveItem")
AddEventHandler('N1Core:Server:RemoveItem', function(itemName, amount, slot)
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	Player.Functions.RemoveItem(itemName, amount, slot)
end)

RegisterServerEvent("N1Core:Server:AddItem")
AddEventHandler('N1Core:Server:AddItem', function(itemName, amount, slot, info)
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	Player.Functions.AddItem(itemName, amount, slot, info)
end)

RegisterServerEvent('N1Core:Server:SetMetaData')
AddEventHandler('N1Core:Server:SetMetaData', function(meta, data)
    local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	if meta == "hunger" or meta == "thirst" then
		if data > 100 then
			data = 100
		end
	end
	if Player ~= nil then 
		Player.Functions.SetMetaData(meta, data)
	end
	TriggerClientEvent("hud:client:UpdateNeeds", src, Player.PlayerData.metadata["hunger"], Player.PlayerData.metadata["thirst"])
end)

AddEventHandler('chatMessage', function(source, n, message)
	if string.sub(message, 1, 1) == "/" then
		local args = N1Core.Shared.SplitStr(message, " ")
		local command = string.gsub(args[1]:lower(), "/", "")
		CancelEvent()
		if N1Core.Commands.List[command] ~= nil then
			local Player = N1Core.Functions.GetPlayer(tonumber(source))
			if Player ~= nil then
				table.remove(args, 1)
				if (N1Core.Functions.HasPermission(source, "god") or N1Core.Functions.HasPermission(source, N1Core.Commands.List[command].permission)) then
					if (N1Core.Commands.List[command].argsrequired and #N1Core.Commands.List[command].arguments ~= 0 and args[#N1Core.Commands.List[command].arguments] == nil) then
					    TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be filled out!")
					    local agus = ""
					    for name, help in pairs(N1Core.Commands.List[command].arguments) do
					    	agus = agus .. " ["..help.name.."]"
					    end
				        TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
					else
						N1Core.Commands.List[command].callback(source, args)
					end
				else
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command!")
				end
			end
		end
	end
end)

RegisterServerEvent('N1Core:CallCommand')
AddEventHandler('N1Core:CallCommand', function(command, args)
	if N1Core.Commands.List[command] ~= nil then
		local Player = N1Core.Functions.GetPlayer(tonumber(source))
		if Player ~= nil then
			if (N1Core.Functions.HasPermission(source, "god")) or (N1Core.Functions.HasPermission(source, N1Core.Commands.List[command].permission)) or (N1Core.Commands.List[command].permission == Player.PlayerData.job.name) then
				if (N1Core.Commands.List[command].argsrequired and #N1Core.Commands.List[command].arguments ~= 0 and args[#N1Core.Commands.List[command].arguments] == nil) then
					TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "All arguments must be filled out!")
					local agus = ""
					for name, help in pairs(N1Core.Commands.List[command].arguments) do
						agus = agus .. " ["..help.name.."]"
					end
					TriggerClientEvent('chatMessage', source, "/"..command, false, agus)
				else
					N1Core.Commands.List[command].callback(source, args)
				end
			else
				TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "No access to this command!")
			end
		end
	end
end)

RegisterServerEvent("N1Core:AddCommand")
AddEventHandler('N1Core:AddCommand', function(name, help, arguments, argsrequired, callback, persmission)
	N1Core.Commands.Add(name, help, arguments, argsrequired, callback, persmission)
end)

RegisterServerEvent("N1Core:ToggleDuty")
AddEventHandler('N1Core:ToggleDuty', function()
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	if Player.PlayerData.job.onduty then
		Player.Functions.SetJobDuty(false)
		TriggerClientEvent('N1Core:Notify', src, "You are now off duty!")
	else
		Player.Functions.SetJobDuty(true)
		TriggerClientEvent('N1Core:Notify', src, "You are now on duty!")
	end
	TriggerClientEvent("N1Core:Client:SetDuty", src, Player.PlayerData.job.onduty)
end)

Citizen.CreateThread(function()
	N1Core.Functions.ExecuteSql(true, "SELECT * FROM `permissions`", function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				N1Core.Config.Server.PermissionList[v.steam] = {
					steam = v.steam,
					license = v.license,
					permission = v.permission,
					optin = true,
				}
			end
		end
	end)
end)

N1Core.Functions.CreateCallback('N1Core:HasItem', function(source, cb, itemName)
	local retval = false
	local Player = N1Core.Functions.GetPlayer(source)
	if Player ~= nil then 
		if Player.Functions.GetItemByName(itemName) ~= nil then
			retval = true
		end
	end
	
	cb(retval)
end)	

RegisterServerEvent('N1Core:Command:CheckOwnedVehicle')
AddEventHandler('N1Core:Command:CheckOwnedVehicle', function(VehiclePlate)
	if VehiclePlate ~= nil then
		N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..VehiclePlate.."'", function(result)
			if result[1] ~= nil then
				N1Core.Functions.ExecuteSql(false, "UPDATE `player_vehicles` SET `state` = '1' WHERE `citizenid` = '"..result[1].citizenid.."'")
				TriggerEvent('N1-garages:server:RemoveVehicle', result[1].citizenid, VehiclePlate)
			end
		end)
	end
end)