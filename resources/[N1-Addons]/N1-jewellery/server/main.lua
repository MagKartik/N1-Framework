N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

local timeOut = false

local alarmTriggered = false

RegisterServerEvent('N1-jewellery:server:setVitrineState')
AddEventHandler('N1-jewellery:server:setVitrineState', function(stateType, state, k)
    Config.Locations[k][stateType] = state
    TriggerClientEvent('N1-jewellery:client:setVitrineState', -1, stateType, state, k)
end)

RegisterServerEvent('N1-jewellery:server:vitrineReward')
AddEventHandler('N1-jewellery:server:vitrineReward', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local otherchance = math.random(1, 4)
    local odd = math.random(1, 4)

    if otherchance == odd then
        local item = math.random(1, #Config.VitrineRewards)
        local amount = math.random(Config.VitrineRewards[item]["amount"]["min"], Config.VitrineRewards[item]["amount"]["max"])
        if Player.Functions.AddItem(Config.VitrineRewards[item]["item"], amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[Config.VitrineRewards[item]["item"]], 'add')
        else
            TriggerClientEvent('N1Core:Notify', src, 'You\'re ..', 'error')
        end
    else
        local amount = math.random(2, 4)
        if Player.Functions.AddItem("10kgoldchain", amount) then
            TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["10kgoldchain"], 'add')
        else
            TriggerClientEvent('N1Core:Notify', src, 'You are carrying to much..', 'error')
        end
    end
end)

RegisterServerEvent('N1-jewellery:server:setTimeout')
AddEventHandler('N1-jewellery:server:setTimeout', function()
    if not timeOut then
        timeOut = true
        TriggerEvent('N1-scoreboard:server:SetActivityBusy', "jewellery", true)
        Citizen.CreateThread(function()
            Citizen.Wait(Config.Timeout)

            for k, v in pairs(Config.Locations) do
                Config.Locations[k]["isOpened"] = false
                TriggerClientEvent('N1-jewellery:client:setVitrineState', -1, 'isOpened', false, k)
                TriggerClientEvent('N1-jewellery:client:setAlertState', -1, false)
                TriggerEvent('N1-scoreboard:server:SetActivityBusy', "jewellery", false)
            end
            timeOut = false
            alarmTriggered = false
        end)
    end
end)

RegisterServerEvent('N1-jewellery:server:PoliceAlertMessage')
AddEventHandler('N1-jewellery:server:PoliceAlertMessage', function(title, coords, blip)
    local src = source
    local alertData = {
        title = title,
        coords = {x = coords.x, y = coords.y, z = coords.z},
        description = "Mogelijk overval gaande bij de Vangelico Juwelier<br>Beschikbare camera's: 31, 32, 33, 34",
    }

    for k, v in pairs(N1Core.Functions.GetPlayers()) do
        local Player = N1Core.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                if blip then
                    if not alarmTriggered then
                        TriggerClientEvent("N1-phone:client:addPoliceAlert", v, alertData)
                        TriggerClientEvent("N1-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                        alarmTriggered = true
                    end
                else
                    TriggerClientEvent("N1-phone:client:addPoliceAlert", v, alertData)
                    TriggerClientEvent("N1-jewellery:client:PoliceAlertMessage", v, title, coords, blip)
                end
            end
        end
    end
end)

N1Core.Functions.CreateCallback('N1-jewellery:server:getCops', function(source, cb)
	local amount = 0
    for k, v in pairs(N1Core.Functions.GetPlayers()) do
        local Player = N1Core.Functions.GetPlayer(v)
        if Player ~= nil then 
            if (Player.PlayerData.job.name == "police" and Player.PlayerData.job.onduty) then
                amount = amount + 1
            end
        end
	end
	cb(amount)
end)