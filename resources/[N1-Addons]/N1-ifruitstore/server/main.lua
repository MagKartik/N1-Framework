N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local alarmTriggered = false
local certificateAmount = 43

RegisterServerEvent('N1-ifruitstore:server:LoadLocationList')
AddEventHandler('N1-ifruitstore:server:LoadLocationList', function()
    local src = source 
    TriggerClientEvent("N1-ifruitstore:server:LoadLocationList", src, Config.Locations)
end)

RegisterServerEvent('N1-ifruitstore:server:setSpotState')
AddEventHandler('N1-ifruitstore:server:setSpotState', function(stateType, state, spot)
    if stateType == "isBusy" then
        Config.Locations["takeables"][spot].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["takeables"][spot].isDone = state
    end
    TriggerClientEvent('N1-ifruitstore:client:setSpotState', -1, stateType, state, spot)
end)

RegisterServerEvent('N1-ifruitstore:server:SetThermiteStatus')
AddEventHandler('N1-ifruitstore:server:SetThermiteStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["thermite"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["thermite"].isDone = state
    end
    TriggerClientEvent('N1-ifruitstore:client:SetThermiteStatus', -1, stateType, state)
end)

RegisterServerEvent('N1-ifruitstore:server:SafeReward')
AddEventHandler('N1-ifruitstore:server:SafeReward', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    Player.Functions.AddMoney('cash', math.random(1500, 2000), "robbery-ifruit")
    Player.Functions.AddItem("certificate", certificateAmount)
    TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["certificate"], "add")
    Citizen.Wait(500)
    local luck = math.random(1, 100)
    if luck <= 10 then
        Player.Functions.AddItem("goldbar", math.random(1, 2))
        TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["goldbar"], "add")
    end
end)

RegisterServerEvent('N1-ifruitstore:server:SetSafeStatus')
AddEventHandler('N1-ifruitstore:server:SetSafeStatus', function(stateType, state)
    if stateType == "isBusy" then
        Config.Locations["safe"].isBusy = state
    elseif stateType == "isDone" then
        Config.Locations["safe"].isDone = state
    end
    TriggerClientEvent('N1-ifruitstore:client:SetSafeStatus', -1, stateType, state)
end)

RegisterServerEvent('N1-ifruitstore:server:itemReward')
AddEventHandler('N1-ifruitstore:server:itemReward', function(spot)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local item = Config.Locations["takeables"][spot].reward

    if Player.Functions.AddItem(item.name, item.amount) then
        TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[item.name], 'add')
    else
        TriggerClientEvent('N1Core:Notify', src, 'You\'re carrying too much..', 'error')
    end    
end)

RegisterServerEvent('N1-ifruitstore:server:PoliceAlertMessage')
AddEventHandler('N1-ifruitstore:server:PoliceAlertMessage', function(msg, coords, blip)
    local src = source
    for k, v in pairs(N1Core.Functions.GetPlayers()) do
        local Player = N1Core.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("N1-jewellery:client:PoliceAlertMessage", v, msg, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("N1-jewellery:client:PoliceAlertMessage", v, msg, coords, blip)
                end
            end
        end
    end
end)