N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

local Pings = {}

N1Core.Commands.Add("ping", "", {{name = "actie", help="id | accept | deny"}}, true, function(source, args)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local task = args[1]
    local PhoneItem = Player.Functions.GetItemByName("phone")

    if PhoneItem ~= nil then
        if task == "accept" then
            if Pings[src] ~= nil then
                TriggerClientEvent('N1-pings:client:AcceptPing', src, Pings[src], N1Core.Functions.GetPlayer(Pings[src].sender))
                TriggerClientEvent('N1Core:Notify', Pings[src].sender, Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname.." accepted your ping!")
                Pings[src] = nil
            else
                TriggerClientEvent('N1Core:Notify', src, "You don't have a ping open..", "error")
            end
        elseif task == "deny" then
            if Pings[src] ~= nil then
                TriggerClientEvent('N1Core:Notify', Pings[src].sender, "Your ping has been rejected..", "error")
                TriggerClientEvent('N1Core:Notify', src, "Tiy rejected the ping..", "success")
                Pings[src] = nil
            else
                TriggerClientEvent('N1Core:Notify', src, "You don't have a ping open..", "error")
            end
        else
            TriggerClientEvent('N1-pings:client:DoPing', src, tonumber(args[1]))
        end
    else
        TriggerClientEvent('N1Core:Notify', src, "You don't have a phone..", "error")
    end
end)

RegisterServerEvent('N1-pings:server:SendPing')
AddEventHandler('N1-pings:server:SendPing', function(id, coords)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local Target = N1Core.Functions.GetPlayer(id)
    local PhoneItem = Player.Functions.GetItemByName("phone")

    if PhoneItem ~= nil then
        if Target ~= nil then
            local OtherItem = Target.Functions.GetItemByName("phone")
            if OtherItem ~= nil then
                TriggerClientEvent('N1Core:Notify', src, "You sent a ping to "..Target.PlayerData.charinfo.firstname.." "..Target.PlayerData.charinfo.lastname)
                Pings[id] = {
                    coords = coords,
                    sender = src,
                }
                TriggerClientEvent('N1Core:Notify', id, "You recived a ping from "..Player.PlayerData.charinfo.firstname.." "..Player.PlayerData.charinfo.lastname..". /ping 'accept | deny'")
            else
                TriggerClientEvent('N1Core:Notify', src, "Could not send the ping, person may dont have a phone.", "error")
            end
        else
            TriggerClientEvent('N1Core:Notify', src, "This person is not online..", "error")
        end
    else
        TriggerClientEvent('N1Core:Notify', src, "You dont have a phone", "error")
    end
end)

RegisterServerEvent('N1-pings:server:SendLocation')
AddEventHandler('N1-pings:server:SendLocation', function(PingData, SenderData)
    TriggerClientEvent('N1-pings:client:SendLocation', PingData.sender, PingData, SenderData)
end)