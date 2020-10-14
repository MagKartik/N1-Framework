N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)
Citizen.CreateThread(function()
	local HouseGarages = {}
	N1Core.Functions.ExecuteSql(false, "SELECT * FROM `houselocations`", function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local owned = false
				if tonumber(v.owned) == 1 then
					owned = true
				end
				local garage = v.garage ~= nil and json.decode(v.garage) or {}
				Config.Houses[v.name] = {
					coords = json.decode(v.coords),
					owned = v.owned,
					price = v.price,
					locked = true,
					adress = v.label, 
					tier = v.tier,
					garage = garage,
					decorations = {},
				}
				HouseGarages[v.name] = {
					label = v.label,
					takeVehicle = garage,
				}
			end
		end
		TriggerClientEvent("N1-garages:client:houseGarageConfig", -1, HouseGarages)
		TriggerClientEvent("N1-houses:client:setHouseConfig", -1, Config.Houses)
	end)
end)

N1Core.Functions.CreateCallback('N1-spawn:server:getOwnedHouses', function(source, cb, cid)
	if cid ~= nil then
		N1Core.Functions.ExecuteSql(false, 'SELECT * FROM `player_houses` WHERE `citizenid` = "'..cid..'"', function(houses)
			if houses[1] ~= nil then
				cb(houses)
			else
				cb(nil)
			end
		end)
	else
		cb(nil)
	end
end)
