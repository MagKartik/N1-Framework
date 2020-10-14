N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local permissions = {
    ["kick"] = "admin",
    ["ban"] = "admin",
    ["noclip"] = "admin",
    ["kickall"] = "admin",
}

RegisterServerEvent('N1-admin:server:togglePlayerNoclip')
AddEventHandler('N1-admin:server:togglePlayerNoclip', function(playerId, reason)
    local src = source
    if N1Core.Functions.HasPermission(src, permissions["noclip"]) then
        TriggerClientEvent("N1-admin:client:toggleNoclip", playerId)
    end
end)

RegisterServerEvent('N1-admin:server:killPlayer')
AddEventHandler('N1-admin:server:killPlayer', function(playerId)
    TriggerClientEvent('hospital:client:KillPlayer', playerId)
end)

RegisterServerEvent('N1-admin:server:kickPlayer')
AddEventHandler('N1-admin:server:kickPlayer', function(playerId, reason)
    local src = source
    if N1Core.Functions.HasPermission(src, permissions["kick"]) then
        DropPlayer(playerId, "You have been kicked from the server:\n"..reason.."\n\n🔸 Join our Discord for further information: https://discord.gg/AbxSaqG")
    end
end)

RegisterServerEvent('N1-admin:server:Freeze')
AddEventHandler('N1-admin:server:Freeze', function(playerId, toggle)
    TriggerClientEvent('N1-admin:client:Freeze', playerId, toggle)
end)

RegisterServerEvent('N1-admin:server:serverKick')
AddEventHandler('N1-admin:server:serverKick', function(reason)
    local src = source
    if N1Core.Functions.HasPermission(src, permissions["kickall"]) then
        for k, v in pairs(N1Core.Functions.GetPlayers()) do
            if v ~= src then 
                DropPlayer(v, "You have been kicked from the server:\n"..reason.."\n\n🔸 Join our Discord for further information: https://discord.gg/AbxSaqG")
            end
        end
    end
end)

RegisterServerEvent('N1-admin:server:banPlayer')
AddEventHandler('N1-admin:server:banPlayer', function(playerId, time, reason)
    local src = source
    if N1Core.Functions.HasPermission(src, permissions["ban"]) then
        local time = tonumber(time)
        local banTime = tonumber(os.time() + time)
        if banTime > 2147483647 then
            banTime = 2147483647
        end
        local timeTable = os.date("*t", banTime)
        TriggerClientEvent('chatMessage', -1, "BANHAMMER", "error", GetPlayerName(playerId).." has been banned for: "..reason.." "..suffix[math.random(1, #suffix)])
        N1Core.Functions.ExecuteSql(false, "INSERT INTO `bans` (`name`, `steam`, `license`, `discord`,`ip`, `reason`, `expire`, `bannedby`) VALUES ('"..GetPlayerName(playerId).."', '"..GetPlayerIdentifiers(playerId)[1].."', '"..GetPlayerIdentifiers(playerId)[2].."', '"..GetPlayerIdentifiers(playerId)[3].."', '"..GetPlayerIdentifiers(playerId)[4].."', '"..reason.."', "..banTime..", '"..GetPlayerName(src).."')")
        DropPlayer(playerId, "You have been banished from the server:\n"..reason.."\n\nBan expires: "..timeTable["day"].. "/" .. timeTable["month"] .. "/" .. timeTable["year"] .. " " .. timeTable["hour"].. ":" .. timeTable["min"] .. "\n🔸 Join our Discord for further information: https://discord.gg/AbxSaqG")
    end
end)

RegisterServerEvent('N1-admin:server:revivePlayer')
AddEventHandler('N1-admin:server:revivePlayer', function(target)
	TriggerClientEvent('hospital:client:Revive', target)
end)

N1Core.Commands.Add("announce", "Announce a message to everyone", {}, false, function(source, args)
    local msg = table.concat(args, " ")
    for i = 1, 3, 1 do
        TriggerClientEvent('chatMessage', -1, "SYSTEM", "error", msg)
    end
end, "admin")

N1Core.Commands.Add("admin", "Open admin menu", {}, false, function(source, args)
    local group = N1Core.Functions.GetPermission(source)
    local dealers = exports['N1-drugs']:GetDealers()
    TriggerClientEvent('N1-admin:client:openMenu', source, group, dealers)
end, "admin")

N1Core.Commands.Add("report", "Send a report to admins (only when necessary, DO NOT ABUSE THIS!)", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-admin:client:SendReport', -1, GetPlayerName(source), source, msg)
    TriggerClientEvent('chatMessage', source, "REPORT Send", "normal", msg)
    TriggerEvent("N1-log:server:CreateLog", "report", "Report", "green", "**"..GetPlayerName(source).."** (CitizenID: "..Player.PlayerData.citizenid.." | ID: "..source..") **Report:** " ..msg, false)
    TriggerEvent("N1-log:server:sendLog", Player.PlayerData.citizenid, "reportreply", {message=msg})
end)

N1Core.Commands.Add("staffchat", "Send a message to all staff members", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")

    TriggerClientEvent('N1-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "admin")

N1Core.Commands.Add("givenuifocus", "Give nui focus", {{name="id", help="Player id"}, {name="focus", help="Set focus on/off"}, {name="mouse", help="Set mouse on/off"}}, true, function(source, args)
    local playerid = tonumber(args[1])
    local focus = args[2]
    local mouse = args[3]

    TriggerClientEvent('N1-admin:client:GiveNuiFocus', playerid, focus, mouse)
end, "admin")

N1Core.Commands.Add("s", "Send a message tot all staff members", {{name="message", help="Message"}}, true, function(source, args)
    local msg = table.concat(args, " ")

    TriggerClientEvent('N1-admin:client:SendStaffChat', -1, GetPlayerName(source), msg)
end, "admin")

N1Core.Commands.Add("warn", "Warn a player", {{name="ID", help="Player"}, {name="Reason", help="Mention a reason"}}, true, function(source, args)
    local targetPlayer = N1Core.Functions.GetPlayer(tonumber(args[1]))
    local senderPlayer = N1Core.Functions.GetPlayer(source)
    table.remove(args, 1)
    local msg = table.concat(args, " ")

    local myName = senderPlayer.PlayerData.name

    local warnId = "WARN-"..math.random(1111, 9999)

    if targetPlayer ~= nil then
        TriggerClientEvent('chatMessage', targetPlayer.PlayerData.source, "SYSTEM", "error", "You have been warned by: "..GetPlayerName(source)..", Reason: "..msg)
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "You have warned "..GetPlayerName(targetPlayer.PlayerData.source).." for: "..msg)
        N1Core.Functions.ExecuteSql(false, "INSERT INTO `player_warns` (`senderIdentifier`, `targetIdentifier`, `reason`, `warnId`) VALUES ('"..senderPlayer.PlayerData.steam.."', '"..targetPlayer.PlayerData.steam.."', '"..msg.."', '"..warnId.."')")
    else
        TriggerClientEvent('N1Core:Notify', source, 'This player is not online', 'error')
    end 
end, "admin")

N1Core.Commands.Add("checkwarns", "Warn a player", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, false, function(source, args)
    if args[2] == nil then
        local targetPlayer = N1Core.Functions.GetPlayer(tonumber(args[1]))
        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_warns` WHERE `targetIdentifier` = '"..targetPlayer.PlayerData.steam.."'", function(result)
            print(json.encode(result))
            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has "..tablelength(result).." warnings!")
        end)
    else
        local targetPlayer = N1Core.Functions.GetPlayer(tonumber(args[1]))

        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_warns` WHERE `targetIdentifier` = '"..targetPlayer.PlayerData.steam.."'", function(warnings)
            local selectedWarning = tonumber(args[2])

            if warnings[selectedWarning] ~= nil then
                local sender = N1Core.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)

                TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", targetPlayer.PlayerData.name.." has been warned by "..sender.PlayerData.name..", Reason: "..warnings[selectedWarning].reason)
            end
        end)
    end
end, "admin")

N1Core.Commands.Add("delwarn", "Delete warnings of a person", {{name="ID", help="Player"}, {name="Warning", help="Number of warning, (1, 2 or 3 etc..)"}}, true, function(source, args)
    local targetPlayer = N1Core.Functions.GetPlayer(tonumber(args[1]))

    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_warns` WHERE `targetIdentifier` = '"..targetPlayer.PlayerData.steam.."'", function(warnings)
        local selectedWarning = tonumber(args[2])

        if warnings[selectedWarning] ~= nil then
            local sender = N1Core.Functions.GetPlayer(warnings[selectedWarning].senderIdentifier)

            TriggerClientEvent('chatMessage', source, "SYSTEM", "warning", "You have deleted warning ("..selectedWarning..") , Reason: "..warnings[selectedWarning].reason)
            N1Core.Functions.ExecuteSql(false, "DELETE FROM `player_warns` WHERE `warnId` = '"..warnings[selectedWarning].warnId.."'")
        end
    end)
end, "admin")

function tablelength(table)
    local count = 0
    for _ in pairs(table) do 
        count = count + 1 
    end
    return count
end

N1Core.Commands.Add("reportr", "Reply to a report", {}, false, function(source, args)
    local playerId = tonumber(args[1])
    table.remove(args, 1)
    local msg = table.concat(args, " ")
    local OtherPlayer = N1Core.Functions.GetPlayer(playerId)
    local Player = N1Core.Functions.GetPlayer(source)
    if OtherPlayer ~= nil then
        TriggerClientEvent('chatMessage', playerId, "ADMIN - "..GetPlayerName(source), "warning", msg)
        TriggerClientEvent('N1Core:Notify', source, "Sent reply")
        TriggerEvent("N1-log:server:sendLog", Player.PlayerData.citizenid, "reportreply", {otherCitizenId=OtherPlayer.PlayerData.citizenid, message=msg})
        for k, v in pairs(N1Core.Functions.GetPlayers()) do
            if N1Core.Functions.HasPermission(v, "admin") then
                if N1Core.Functions.IsOptin(v) then
                    TriggerClientEvent('chatMessage', v, "ReportReply("..source..") - "..GetPlayerName(source), "warning", msg)
                    TriggerEvent("N1-log:server:CreateLog", "report", "Report Reply", "red", "**"..GetPlayerName(source).."** replied on: **"..OtherPlayer.PlayerData.name.. " **(ID: "..OtherPlayer.PlayerData.source..") **Message:** " ..msg, false)
                end
            end
        end
    else
        TriggerClientEvent('N1Core:Notify', source, "Player is not online", "error")
    end
end, "admin")

N1Core.Commands.Add("setmodel", "Change to a model you like..", {{name="model", help="Name of the model"}, {name="id", help="Id of the Player (empty for yourself)"}}, false, function(source, args)
    local model = args[1]
    local target = tonumber(args[2])

    if model ~= nil or model ~= "" then
        if target == nil then
            TriggerClientEvent('N1-admin:client:SetModel', source, tostring(model))
        else
            local Trgt = N1Core.Functions.GetPlayer(target)
            if Trgt ~= nil then
                TriggerClientEvent('N1-admin:client:SetModel', target, tostring(model))
            else
                TriggerClientEvent('N1Core:Notify', source, "This person is not online..", "error")
            end
        end
    else
        TriggerClientEvent('N1Core:Notify', source, "You did not set a model..", "error")
    end
end, "admin")

N1Core.Commands.Add("setspeed", "Change to a speed you like..", {}, false, function(source, args)
    local speed = args[1]

    if speed ~= nil then
        TriggerClientEvent('N1-admin:client:SetSpeed', source, tostring(speed))
    else
        TriggerClientEvent('N1Core:Notify', source, "You did not set a speed.. (`fast` for super-run, `normal` for normal)", "error")
    end
end, "admin")


N1Core.Commands.Add("admincar", "Save vehicle in your garage", {}, false, function(source, args)
    local ply = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-admin:client:SaveCar', source)
end, "admin")

RegisterServerEvent('N1-admin:server:SaveCar')
AddEventHandler('N1-admin:server:SaveCar', function(mods, vehicle, hash, plate)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `player_vehicles` WHERE `plate` = '"..plate.."'", function(result)
        if result[1] == nil then
            N1Core.Functions.ExecuteSql(false, "INSERT INTO `player_vehicles` (`steam`, `citizenid`, `vehicle`, `hash`, `mods`, `plate`, `state`) VALUES ('"..Player.PlayerData.steam.."', '"..Player.PlayerData.citizenid.."', '"..vehicle.model.."', '"..vehicle.hash.."', '"..json.encode(mods).."', '"..plate.."', 0)")
            TriggerClientEvent('N1Core:Notify', src, 'The vehicle is now yours!', 'success', 5000)
        else
            TriggerClientEvent('N1Core:Notify', src, 'This vehicle is already yours..', 'error', 3000)
        end
    end)
end)

N1Core.Commands.Add("reporttoggle", "Toggle incoming reports", {}, false, function(source, args)
    N1Core.Functions.ToggleOptin(source)
    if N1Core.Functions.IsOptin(source) then
        TriggerClientEvent('N1Core:Notify', source, "You are receiving reports", "success")
    else
        TriggerClientEvent('N1Core:Notify', source, "You are not receiving reports", "error")
    end
end, "admin")

RegisterCommand("kickall", function(source, args, rawCommand)
    local src = source
    
    if src > 0 then
        local reason = table.concat(args, ' ')
        local Player = N1Core.Functions.GetPlayer(src)

        if N1Core.Functions.HasPermission(src, "god") then
            if args[1] ~= nil then
                for k, v in pairs(N1Core.Functions.GetPlayers()) do
                    local Player = N1Core.Functions.GetPlayer(v)
                    if Player ~= nil then 
                        DropPlayer(Player.PlayerData.source, reason)
                    end
                end
            else
                TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'Mention a reason..')
            end
        else
            TriggerClientEvent('chatMessage', src, 'SYSTEM', 'error', 'You can\'t do this..')
        end
    else
        for k, v in pairs(N1Core.Functions.GetPlayers()) do
            local Player = N1Core.Functions.GetPlayer(v)
            if Player ~= nil then 
                DropPlayer(Player.PlayerData.source, "Server restart, check our Discord for more information! (discord.gg/ChangeInN1-adminMainLua)")
            end
        end
    end
end, false)

RegisterServerEvent('N1-admin:server:bringTp')
AddEventHandler('N1-admin:server:bringTp', function(targetId, coords)
    TriggerClientEvent('N1-admin:client:bringTp', targetId, coords)
end)

N1Core.Functions.CreateCallback('N1-admin:server:hasPermissions', function(source, cb, group)
    local src = source
    local retval = false

    if N1Core.Functions.HasPermission(src, group) then
        retval = true
    end
    cb(retval)
end)

RegisterServerEvent('N1-admin:server:setPermissions')
AddEventHandler('N1-admin:server:setPermissions', function(targetId, group)
    N1Core.Functions.AddPermission(targetId, group.rank)
    TriggerClientEvent('N1Core:Notify', targetId, 'Your permission levels have been set to '..group.label)
end)

RegisterServerEvent('N1-admin:server:OpenSkinMenu')
AddEventHandler('N1-admin:server:OpenSkinMenu', function(targetId)
    TriggerClientEvent("N1-clothing:client:openMenu", targetId)
end)

RegisterServerEvent('N1-admin:server:SendReport')
AddEventHandler('N1-admin:server:SendReport', function(name, targetSrc, msg)
    local src = source
    local Players = N1Core.Functions.GetPlayers()

    if N1Core.Functions.HasPermission(src, "admin") then
        if N1Core.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "REPORT - "..name.." ("..targetSrc..")", "report", msg)
        end
    end
end)

RegisterServerEvent('N1-admin:server:StaffChatMessage')
AddEventHandler('N1-admin:server:StaffChatMessage', function(name, msg)
    local src = source
    local Players = N1Core.Functions.GetPlayers()

    if N1Core.Functions.HasPermission(src, "admin") then
        if N1Core.Functions.IsOptin(src) then
            TriggerClientEvent('chatMessage', src, "STAFFCHAT - "..name, "error", msg)
        end
    end
end)

N1Core.Commands.Add("setammo", "Staff: Set manual ammo for a weapon.", {{name="amount", help="Amount of bullets, for example: 20"}, {name="weapon", help="Name of the weapen, for example: WEAPON_VINTAGEPISTOL"}}, false, function(source, args)
    local src = source
    local weapon = args[2]
    local amount = tonumber(args[1])

    if weapon ~= nil then
        TriggerClientEvent('N1-weapons:client:SetWeaponAmmoManual', src, weapon, amount)
    else
        TriggerClientEvent('N1-weapons:client:SetWeaponAmmoManual', src, "current", amount)
    end
end, 'admin')
