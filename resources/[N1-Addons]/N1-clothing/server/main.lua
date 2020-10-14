N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Commands.Add("skin", "Reset Your Char - [Admin]", {}, false, function(source, args)
	TriggerClientEvent("N1-clothing:client:openMenu", source)
end, "admin")

RegisterServerEvent("N1-clothing:saveSkin")
AddEventHandler('N1-clothing:saveSkin', function(model, skin)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if model ~= nil and skin ~= nil then 
        N1Core.Functions.ExecuteSql(false, "DELETE FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function()
            N1Core.Functions.ExecuteSql(false, "INSERT INTO `playerskins` (`citizenid`, `model`, `skin`, `active`) VALUES ('"..Player.PlayerData.citizenid.."', '"..model.."', '"..skin.."', 1)")
        end)
    end
end)

RegisterServerEvent("N1-clothes:loadPlayerSkin")
AddEventHandler('N1-clothes:loadPlayerSkin', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `playerskins` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `active` = 1", function(result)
        if result[1] ~= nil then
            TriggerClientEvent("N1-clothes:loadSkin", src, false, result[1].model, result[1].skin)
        else
            TriggerClientEvent("N1-clothes:loadSkin", src, true)
        end
    end)
end)

RegisterServerEvent("N1-clothes:saveOutfit")
AddEventHandler("N1-clothes:saveOutfit", function(outfitName, model, skinData)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if model ~= nil and skinData ~= nil then
        local outfitId = "outfit-"..math.random(1, 10).."-"..math.random(1111, 9999)
        N1Core.Functions.ExecuteSql(false, "INSERT INTO `player_outfits` (`citizenid`, `outfitname`, `model`, `skin`, `outfitId`) VALUES ('"..Player.PlayerData.citizenid.."', '"..outfitName.."', '"..model.."', '"..json.encode(skinData).."', '"..outfitId.."')", function()
            N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
                if result[1] ~= nil then
                    TriggerClientEvent('N1-clothing:client:reloadOutfits', src, result)
                else
                    TriggerClientEvent('N1-clothing:client:reloadOutfits', src, nil)
                end
            end)
        end)
    end
end)

RegisterServerEvent("N1-clothing:server:removeOutfit")
AddEventHandler("N1-clothing:server:removeOutfit", function(outfitName, outfitId)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    N1Core.Functions.ExecuteSql(false, "DELETE FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."' AND `outfitname` = '"..outfitName.."' AND `outfitId` = '"..outfitId.."'", function()
        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
            if result[1] ~= nil then
                TriggerClientEvent('N1-clothing:client:reloadOutfits', src, result)
            else
                TriggerClientEvent('N1-clothing:client:reloadOutfits', src, nil)
            end
        end)
    end)
end)

N1Core.Functions.CreateCallback('N1-clothing:server:getOutfits', function(source, cb)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local anusVal = {}

    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_outfits` WHERE `citizenid` = '"..Player.PlayerData.citizenid.."'", function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                result[k].skin = json.decode(result[k].skin)
                anusVal[k] = v
            end
            cb(anusVal)
        end
        cb(anusVal)
    end)
end)

RegisterServerEvent('N1-clothing:print')
AddEventHandler('N1-clothing:print', function(data)
    print(data)
end)

N1Core.Commands.Add("helmet", "Put your helmet/cap/hat on or off..", {}, false, function(source, args)
    TriggerClientEvent("N1-clothing:client:adjustfacewear", source, 1) -- Hat
end)

N1Core.Commands.Add("glasses", "Put your glasses on or off..", {}, false, function(source, args)
	TriggerClientEvent("N1-clothing:client:adjustfacewear", source, 2)
end)

N1Core.Commands.Add("masks", "Put your mask on or off..", {}, false, function(source, args)
	TriggerClientEvent("N1-clothing:client:adjustfacewear", source, 4)
end)