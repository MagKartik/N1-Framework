local CurrentDivingArea = math.random(1, #N1Diving.Locations)

N1Core.Functions.CreateCallback('N1-diving:server:GetDivingConfig', function(source, cb)
    cb(N1Diving.Locations, CurrentDivingArea)
end)

RegisterServerEvent('N1-diving:server:TakeCoral')
AddEventHandler('N1-diving:server:TakeCoral', function(Area, Coral, Bool)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local CoralType = math.random(1, #N1Diving.CoralTypes)
    local Amount = math.random(1, N1Diving.CoralTypes[CoralType].maxAmount)
    local ItemData = N1Core.Shared.Items[N1Diving.CoralTypes[CoralType].item]

    if Amount > 1 then
        for i = 1, Amount, 1 do
            Player.Functions.AddItem(ItemData["name"], 1)
            TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
            Citizen.Wait(250)
        end
    else
        Player.Functions.AddItem(ItemData["name"], Amount)
        TriggerClientEvent('inventory:client:ItemBox', src, ItemData, "add")
    end

    if (N1Diving.Locations[Area].TotalCoral - 1) == 0 then
        for k, v in pairs(N1Diving.Locations[CurrentDivingArea].coords.Coral) do
            v.PickedUp = false
        end
        N1Diving.Locations[CurrentDivingArea].TotalCoral = N1Diving.Locations[CurrentDivingArea].DefaultCoral

        local newLocation = math.random(1, #N1Diving.Locations)
        while (newLocation == CurrentDivingArea) do
            Citizen.Wait(3)
            newLocation = math.random(1, #N1Diving.Locations)
        end
        CurrentDivingArea = newLocation
        
        TriggerClientEvent('N1-diving:client:NewLocations', -1)
    else
        N1Diving.Locations[Area].coords.Coral[Coral].PickedUp = Bool
        N1Diving.Locations[Area].TotalCoral = N1Diving.Locations[Area].TotalCoral - 1
    end

    TriggerClientEvent('N1-diving:server:UpdateCoral', -1, Area, Coral, Bool)
end)

RegisterServerEvent('N1-diving:server:RemoveGear')
AddEventHandler('N1-diving:server:RemoveGear', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    Player.Functions.RemoveItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["diving_gear"], "remove")
end)

RegisterServerEvent('N1-diving:server:GiveBackGear')
AddEventHandler('N1-diving:server:GiveBackGear', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    
    Player.Functions.AddItem("diving_gear", 1)
    TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["diving_gear"], "add")
end)