N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

RegisterServerEvent('N1-multicharacter:server:disconnect')
AddEventHandler('N1-multicharacter:server:disconnect', function()
    local src = source

    DropPlayer(src, "You have disconnected from N1us Roleplay")
end)

RegisterServerEvent('N1-multicharacter:server:loadUserData')
AddEventHandler('N1-multicharacter:server:loadUserData', function(cData)
    local src = source
    if N1Core.Player.Login(src, cData.citizenid) then
        print('^2[N1Core]^7 '..GetPlayerName(src)..' (Citizen ID: '..cData.citizenid..') has succesfully loaded!')
        N1Core.Commands.Refresh(src)
        loadHouseData()
		--TriggerEvent('N1Core:Server:OnPlayerLoaded')-
        --TriggerClientEvent('N1Core:Client:OnPlayerLoaded', src)
        
        TriggerClientEvent('apartments:client:setupSpawnUI', src, cData)
        TriggerEvent("N1-log:server:sendLog", cData.citizenid, "characterloaded", {})
        TriggerEvent("N1-log:server:CreateLog", "joinleave", "Loaded", "green", "**".. GetPlayerName(src) .. "** ("..cData.citizenid.." | "..src..") loaded..")
	end
end)

RegisterServerEvent('N1-multicharacter:server:createCharacter')
AddEventHandler('N1-multicharacter:server:createCharacter', function(data)
    local src = source
    local newData = {}
    newData.cid = data.cid
    newData.charinfo = data
    --N1Core.Player.CreateCharacter(src, data)
    if N1Core.Player.Login(src, false, newData) then
        print('^2[N1Core]^7 '..GetPlayerName(src)..' has succesfully loaded!')
        N1Core.Commands.Refresh(src)
        loadHouseData()

        TriggerClientEvent("N1-multicharacter:client:closeNUI", src)
        TriggerClientEvent('apartments:client:setupSpawnUI', src, newData)
        GiveStarterItems(src)
	end
end)

function GiveStarterItems(source)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    for k, v in pairs(N1Core.Shared.StarterItems) do
        local info = {}
        if v.item == "id_card" then
            info.citizenid = Player.PlayerData.citizenid
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.gender = Player.PlayerData.charinfo.gender
            info.nationality = Player.PlayerData.charinfo.nationality
        elseif v.item == "driver_license" then
            info.firstname = Player.PlayerData.charinfo.firstname
            info.lastname = Player.PlayerData.charinfo.lastname
            info.birthdate = Player.PlayerData.charinfo.birthdate
            info.type = "A1-A2-A | AM-B | C1-C-CE"
        end
        Player.Functions.AddItem(v.item, 1, false, info)
    end
end

RegisterServerEvent('N1-multicharacter:server:deleteCharacter')
AddEventHandler('N1-multicharacter:server:deleteCharacter', function(citizenid)
    local src = source
    N1Core.Player.DeleteCharacter(src, citizenid)
end)

N1Core.Functions.CreateCallback("N1-multicharacter:server:GetUserCharacters", function(source, cb)
    local steamId = GetPlayerIdentifier(source, 0)

    exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @steam', {['@steam'] = steamId}, function(result)
        cb(result)
    end)
end)

N1Core.Functions.CreateCallback("N1-multicharacter:server:GetServerLogs", function(source, cb)
    exports['ghmattimysql']:execute('SELECT * FROM server_logs', function(result)
        cb(result)
    end)
end)

N1Core.Functions.CreateCallback("test:yeet", function(source, cb)
    local steamId = GetPlayerIdentifiers(source)[1]
    local plyChars = {}
    
    exports['ghmattimysql']:execute('SELECT * FROM players WHERE steam = @steam', {['@steam'] = steamId}, function(result)
        for i = 1, (#result), 1 do
            result[i].charinfo = json.decode(result[i].charinfo)
            result[i].money = json.decode(result[i].money)
            result[i].job = json.decode(result[i].job)

            table.insert(plyChars, result[i])
        end
        cb(plyChars)
    end)
end)

N1Core.Commands.Add("char", "Give item to a player", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, false, function(source, args)
    N1Core.Player.Logout(source)
    TriggerClientEvent('N1-multicharacter:client:chooseChar', source)
end, "admin")

N1Core.Commands.Add("closeNUI", "Give item to a player", {{name="id", help="Player ID"},{name="item", help="Name of the item (not a label)"}, {name="amount", help="Amount of items"}}, false, function(source, args)
    TriggerClientEvent('N1-multicharacter:client:closeNUI', source)
end)

N1Core.Functions.CreateCallback("N1-multicharacter:server:getSkin", function(source, cb, cid)
    local src = source

    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..cid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            cb(result[1].model, result[1].skin)
        else
            cb(nil)
        end
    end)
end)

function loadHouseData()
    local HouseGarages = {}
    local Houses = {}
	N1Core.Functions.ExecuteSql(false, "SELECT * FROM `houselocations`", function(result)
		if result[1] ~= nil then
			for k, v in pairs(result) do
				local owned = false
				if tonumber(v.owned) == 1 then
					owned = true
				end
				local garage = v.garage ~= nil and json.decode(v.garage) or {}
				Houses[v.name] = {
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
		TriggerClientEvent("N1-houses:client:setHouseConfig", -1, Houses)
	end)
end