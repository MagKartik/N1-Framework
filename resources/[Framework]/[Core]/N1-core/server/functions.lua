N1Core.Functions = {}

N1Core.Functions.ExecuteSql = function(wait, query, cb)
	local rtndata = {}
	local waiting = true
	exports['ghmattimysql']:execute(query, {}, function(data)
		if cb ~= nil and wait == false then
			cb(data)
		end
		rtndata = data
		waiting = false
	end)
	if wait then
		while waiting do
			Citizen.Wait(5)
		end
		if cb ~= nil and wait == true then
			cb(rtndata)
		end
	end
	return rtndata
end

N1Core.Functions.GetIdentifier = function(source, idtype)
	local idtype = idtype ~=nil and idtype or N1Config.IdentifierType
	for _, identifier in pairs(GetPlayerIdentifiers(source)) do
		if string.find(identifier, idtype) then
			return identifier
		end
	end
	return nil
end

N1Core.Functions.GetSource = function(identifier)
	for src, player in pairs(N1Core.Players) do
		local idens = GetPlayerIdentifiers(src)
		for _, id in pairs(idens) do
			if identifier == id then
				return src
			end
		end
	end
	return 0
end

N1Core.Functions.GetPlayer = function(source)
	if type(source) == "number" then
		return N1Core.Players[source]
	else
		return N1Core.Players[N1Core.Functions.GetSource(source)]
	end
end

N1Core.Functions.GetPlayerByCitizenId = function(citizenid)
	for src, player in pairs(N1Core.Players) do
		local cid = citizenid
		if N1Core.Players[src].PlayerData.citizenid == cid then
			return N1Core.Players[src]
		end
	end
	return nil
end

N1Core.Functions.GetPlayerByPhone = function(number)
	for src, player in pairs(N1Core.Players) do
		local cid = citizenid
		if N1Core.Players[src].PlayerData.charinfo.phone == number then
			return N1Core.Players[src]
		end
	end
	return nil
end

N1Core.Functions.GetPlayers = function()
	local sources = {}
	for k, v in pairs(N1Core.Players) do
		table.insert(sources, k)
	end
	return sources
end

N1Core.Functions.CreateCallback = function(name, cb)
	N1Core.ServerCallbacks[name] = cb
end

N1Core.Functions.TriggerCallback = function(name, source, cb, ...)
	if N1Core.ServerCallbacks[name] ~= nil then
		N1Core.ServerCallbacks[name](source, cb, ...)
	end
end

N1Core.Functions.CreateUseableItem = function(item, cb)
	N1Core.UseableItems[item] = cb
end

N1Core.Functions.CanUseItem = function(item)
	return N1Core.UseableItems[item] ~= nil
end

N1Core.Functions.UseItem = function(source, item)
	N1Core.UseableItems[item.name](source, item)
end

N1Core.Functions.Kick = function(source, reason, setKickReason, deferrals)
	local src = source
	reason = "\n"..reason.."\n🔸 Check our Discord for further information: "..N1Core.Config.Server.discord
	if(setKickReason ~=nil) then
		setKickReason(reason)
	end
	Citizen.CreateThread(function()
		if(deferrals ~= nil)then
			deferrals.update(reason)
			Citizen.Wait(2500)
		end
		if src ~= nil then
			DropPlayer(src, reason)
		end
		local i = 0
		while (i <= 4) do
			i = i + 1
			while true do
				if src ~= nil then
					if(GetPlayerPing(src) >= 0) then
						break
					end
					Citizen.Wait(100)
					Citizen.CreateThread(function() 
						DropPlayer(src, reason)
					end)
				end
			end
			Citizen.Wait(5000)
		end
	end)
end

N1Core.Functions.IsWhitelisted = function(source)
	local identifiers = GetPlayerIdentifiers(source)
	local rtn = false
	if (N1Core.Config.Server.whitelist) then
		N1Core.Functions.ExecuteSql(true, "SELECT * FROM `whitelist` WHERE `"..N1Core.Config.IdentifierType.."` = '".. N1Core.Functions.GetIdentifier(source).."'", function(result)
			local data = result[1]
			if data ~= nil then
				for _, id in pairs(identifiers) do
					if data.steam == id or data.license == id then
						rtn = true
					end
				end
			end
		end)
	else
		rtn = true
	end
	return rtn
end

N1Core.Functions.AddPermission = function(source, permission)
	local Player = N1Core.Functions.GetPlayer(source)
	if Player ~= nil then 
		N1Core.Config.Server.PermissionList[GetPlayerIdentifiers(source)[1]] = {
			steam = GetPlayerIdentifiers(source)[1],
			license = GetPlayerIdentifiers(source)[2],
			permission = permission:lower(),
		}
		N1Core.Functions.ExecuteSql(true, "DELETE FROM `permissions` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		N1Core.Functions.ExecuteSql(true, "INSERT INTO `permissions` (`name`, `steam`, `license`, `permission`) VALUES ('"..GetPlayerName(source).."', '"..GetPlayerIdentifiers(source)[1].."', '"..GetPlayerIdentifiers(source)[2].."', '"..permission:lower().."')")
		Player.Functions.UpdatePlayerData()
		TriggerClientEvent('N1Core:Client:OnPermissionUpdate', source, permission)
	end
end

N1Core.Functions.RemovePermission = function(source)
	local Player = N1Core.Functions.GetPlayer(source)
	if Player ~= nil then 
		N1Core.Config.Server.PermissionList[GetPlayerIdentifiers(source)[1]] = nil	
		N1Core.Functions.ExecuteSql(true, "DELETE FROM `permissions` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."'")
		Player.Functions.UpdatePlayerData()
	end
end

N1Core.Functions.HasPermission = function(source, permission)
	local retval = false
	local steamid = GetPlayerIdentifiers(source)[1]
	local licenseid = GetPlayerIdentifiers(source)[2]
	local permission = tostring(permission:lower())
	if permission == "user" then
		retval = true
	else
		if N1Core.Config.Server.PermissionList[steamid] ~= nil then 
			if N1Core.Config.Server.PermissionList[steamid].steam == steamid and N1Core.Config.Server.PermissionList[steamid].license == licenseid then
				if N1Core.Config.Server.PermissionList[steamid].permission == permission or N1Core.Config.Server.PermissionList[steamid].permission == "god" then
					retval = true
				end
			end
		end
	end
	return retval
end

N1Core.Functions.GetPermission = function(source)
	local retval = "user"
	Player = N1Core.Functions.GetPlayer(source)
	local steamid = GetPlayerIdentifiers(source)[1]
	local licenseid = GetPlayerIdentifiers(source)[2]
	if Player ~= nil then
		if N1Core.Config.Server.PermissionList[Player.PlayerData.steam] ~= nil then 
			if N1Core.Config.Server.PermissionList[Player.PlayerData.steam].steam == steamid and N1Core.Config.Server.PermissionList[Player.PlayerData.steam].license == licenseid then
				retval = N1Core.Config.Server.PermissionList[Player.PlayerData.steam].permission
			end
		end
	end
	return retval
end

N1Core.Functions.IsOptin = function(source)
	local retval = false
	local steamid = GetPlayerIdentifiers(source)[1]
	if N1Core.Functions.HasPermission(source, "admin") then
		retval = N1Core.Config.Server.PermissionList[steamid].optin
	end
	return retval
end

N1Core.Functions.ToggleOptin = function(source)
	local steamid = GetPlayerIdentifiers(source)[1]
	if N1Core.Functions.HasPermission(source, "admin") then
		N1Core.Config.Server.PermissionList[steamid].optin = not N1Core.Config.Server.PermissionList[steamid].optin
	end
end

N1Core.Functions.IsPlayerBanned = function (source)
	local retval = false
	local message = ""
	N1Core.Functions.ExecuteSql(true, "SELECT * FROM `bans` WHERE `steam` = '"..GetPlayerIdentifiers(source)[1].."' OR `license` = '"..GetPlayerIdentifiers(source)[2].."' OR `ip` = '"..GetPlayerIdentifiers(source)[3].."'", function(result)
		if result[1] ~= nil then 
			if os.time() < result[1].expire then
				retval = true
				local timeTable = os.date("*t", tonumber(result[1].expire))
				message = "You have been banned from the server:\n"..result[1].reason.."\nJe ban verloopt "..timeTable.day.. "/" .. timeTable.month .. "/" .. timeTable.year .. " " .. timeTable.hour.. ":" .. timeTable.min .. "\n"
			else
				N1Core.Functions.ExecuteSql(true, "DELETE FROM `bans` WHERE `id` = "..result[1].id)
			end
		end
	end)
	return retval, message
end

