N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Functions.CreateCallback('N1-houserobbery:server:GetHouseConfig', function(source, cb)
    cb(Config.Houses)
end)

RegisterServerEvent('N1-houserobbery:server:enterHouse')
AddEventHandler('N1-houserobbery:server:enterHouse', function(house)
    local src = source
    local itemInfo = N1Core.Shared.Items["lockpick"]
    local Player = N1Core.Functions.GetPlayer(src)
    
    if not Config.Houses[house]["opened"] then
        ResetHouseStateTimer(house)
        TriggerClientEvent('N1-houserobbery:client:setHouseState', -1, house, true)
    end
    TriggerClientEvent('N1-houserobbery:client:enterHouse', src, house)
    Config.Houses[house]["opened"] = true
end)

function ResetHouseStateTimer(house)
    -- Cannot parse math.random "directly" inside the tonumber function
    local num = math.random(3333333, 11111111)
    local time = tonumber(num)
    Citizen.SetTimeout(time, function()
        Config.Houses[house]["opened"] = false
        for k, v in pairs(Config.Houses[house]["furniture"]) do
            v["searched"] = false
        end
        TriggerClientEvent('N1-houserobbery:client:ResetHouseState', -1, house)
    end)
end

RegisterServerEvent('N1-houserobbery:server:searchCabin')
AddEventHandler('N1-houserobbery:server:searchCabin', function(cabin, house)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local luck = math.random(1, 10)
    local itemFound = math.random(1, 4)
    local itemCount = 1

    local Tier = 1
    if Config.Houses[house]["tier"] == 1 then
        Tier = 1
    elseif Config.Houses[house]["tier"] == 2 then
        Tier = 2
    elseif Config.Houses[house]["tier"] == 3 then
        Tier = 3
    end

    if itemFound < 4 then
        if luck == 10 then
            itemCount = 3
        elseif luck >= 6 and luck <= 8 then
            itemCount = 2
        end

        for i = 1, itemCount, 1 do
            local randomItem = Config.Rewards[Tier][Config.Houses[house]["furniture"][cabin]["type"]][math.random(1, #Config.Rewards[Tier][Config.Houses[house]["furniture"][cabin]["type"]])]
            local itemInfo = N1Core.Shared.Items[randomItem]
            if math.random(1, 100) == 69 then
                randomItem = "painkillers"
                itemInfo = N1Core.Shared.Items[randomItem]
                Player.Functions.AddItem(randomItem, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
            else
                if not itemInfo["unqiue"] then
                    local itemAmount = math.random(1, 3)
                    if randomItem == "plastic" then
                        itemAmount = math.random(15, 30)
                    elseif randomItem == "goldchain" then
                        itemAmount = math.random(5, 8)
                    end
                    Player.Functions.AddItem(randomItem, itemAmount)
                else
                    Player.Functions.AddItem(randomItem, 1)
                end
                TriggerClientEvent('inventory:client:ItemBox', src, itemInfo, "add")
            end
            Citizen.Wait(500)
            -- local weaponChance = math.random(1, 100)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'The cabin is empty bro', 'error', 3500)
    end

    Config.Houses[house]["furniture"][cabin]["searched"] = true
    TriggerClientEvent('N1-houserobbery:client:setCabinState', -1, house, cabin, true)
end)

RegisterServerEvent('N1-houserobbery:server:SetBusyState')
AddEventHandler('N1-houserobbery:server:SetBusyState', function(cabin, house, bool)
    Config.Houses[house]["furniture"][cabin]["isBusy"] = bool
    TriggerClientEvent('N1-houserobbery:client:SetBusyState', -1, cabin, house, bool)
end)
