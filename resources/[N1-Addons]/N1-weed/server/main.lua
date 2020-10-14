N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

--CODE

N1Core.Functions.CreateCallback('N1-weed:server:getBuildingPlants', function(source, cb, building)
    local buildingPlants = {}

    exports['ghmattimysql']:execute('SELECT * FROM house_plants WHERE building = @building', {['@building'] = building}, function(plants)
        for i = 1, #plants, 1 do
            table.insert(buildingPlants, plants[i])
        end

        if buildingPlants ~= nil then
            cb(buildingPlants)
        else    
            cb(nil)
        end
    end)
end)

N1Core.Commands.Add("plaatsplant", "", {}, false, function(source, args)
    local src           = source
    local player        = N1Core.Functions.GetPlayer(src)
    local type          = args[1]

    if N1Weed.Plants[type] ~= nil then
        TriggerClientEvent('N1-weed:client:placePlant', src, type)
    end
end)

RegisterServerEvent('N1-weed:server:placePlant')
AddEventHandler('N1-weed:server:placePlant', function(currentHouse, coords, sort)
    local random = math.random(1, 2)
    local gender
    if random == 1 then gender = "man" else gender = "woman" end

    N1Core.Functions.ExecuteSql(true, "INSERT INTO `house_plants` (`building`, `coords`, `gender`, `sort`, `plantid`) VALUES ('"..currentHouse.."', '"..coords.."', '"..gender.."', '"..sort.."', '"..math.random(111111,999999).."')")
    TriggerClientEvent('N1-weed:client:refreshHousePlants', -1, currentHouse)
end)

RegisterServerEvent('N1-weed:server:removeDeathPlant')
AddEventHandler('N1-weed:server:removeDeathPlant', function(building, plantId)
    N1Core.Functions.ExecuteSql(true, "DELETE FROM `house_plants` WHERE plantid = '"..plantId.."' AND building = '"..building.."'")
    TriggerClientEvent('N1-weed:client:refreshHousePlants', -1, building)
end)

Citizen.CreateThread(function()
    while true do
        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `house_plants`", function(housePlants)
            for k, v in pairs(housePlants) do
                if housePlants[k].food >= 50 then
                    N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `food` = '"..(housePlants[k].food - 1).."' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                    if housePlants[k].health + 1 < 100 then
                        N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `health` = '"..(housePlants[k].health + 1).."' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                    end
                end

                if housePlants[k].food < 50 then
                    if housePlants[k].food - 1 >= 0 then
                        N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `food` = '"..(housePlants[k].food - 1).."' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                    end
                    if housePlants[k].health - 1 >= 0 then
                        N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `health` = '"..(housePlants[k].health - 1).."' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                    end
                end
            end

            TriggerClientEvent('N1-weed:client:refreshPlantStats', -1)
        end)

        Citizen.Wait((60 * 1000) * 19.2)
    end
end)

Citizen.CreateThread(function()
    while true do
        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `house_plants`", function(housePlants)
            for k, v in pairs(housePlants) do
                if housePlants[k].health > 50 then
                    local Grow = math.random(1, 3)
                    if housePlants[k].progress + Grow < 100 then
                        N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `progress` = '"..(housePlants[k].progress + 1).."' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                    elseif housePlants[k].progress + Grow >= 100 then
                        if housePlants[k].stage ~= N1Weed.Plants[housePlants[k].sort]["highestStage"] then
                            if housePlants[k].stage == "stage-a" then
                                N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `stage` = 'stage-b' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                            elseif housePlants[k].stage == "stage-b" then
                                N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `stage` = 'stage-c' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                            elseif housePlants[k].stage == "stage-c" then
                                N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `stage` = 'stage-d' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                            elseif housePlants[k].stage == "stage-d" then
                                N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `stage` = 'stage-e' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                            elseif housePlants[k].stage == "stage-e" then
                                N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `stage` = 'stage-f' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                            elseif housePlants[k].stage == "stage-f" then
                                N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `stage` = 'stage-g' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                            end
                            N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `progress` = '0' WHERE `plantid` = '"..housePlants[k].plantid.."'")
                        end
                    end
                end
            end

            TriggerClientEvent('N1-weed:client:refreshPlantStats', -1)
        end)

        Citizen.Wait((60 * 1000) * 9.6)
    end
end)

N1Core.Functions.CreateUseableItem("weed_white-widow_seed", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:placePlant', source, 'white-widow', item)
end)

N1Core.Functions.CreateUseableItem("weed_skunk_seed", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:placePlant', source, 'skunk', item)
end)

N1Core.Functions.CreateUseableItem("weed_purple-haze_seed", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:placePlant', source, 'purple-haze', item)
end)

N1Core.Functions.CreateUseableItem("weed_og-kush_seed", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:placePlant', source, 'og-kush', item)
end)

N1Core.Functions.CreateUseableItem("weed_amnesia_seed", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:placePlant', source, 'amnesia', item)
end)

N1Core.Functions.CreateUseableItem("weed_ak47_seed", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:placePlant', source, 'ak47', item)
end)

N1Core.Functions.CreateUseableItem("weed_nutrition", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent('N1-weed:client:foodPlant', source, item)
end)

RegisterServerEvent('N1-weed:server:removeSeed')
AddEventHandler('N1-weed:server:removeSeed', function(itemslot, seed)
    local Player = N1Core.Functions.GetPlayer(source)
    Player.Functions.RemoveItem(seed, 1, itemslot)
end)

RegisterServerEvent('N1-weed:server:harvestPlant')
AddEventHandler('N1-weed:server:harvestPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local weedBag = Player.Functions.GetItemByName('empty_weed_bag')
    local sndAmount = math.random(12, 16)

    if weedBag ~= nil then
        if weedBag.amount >= sndAmount then
            if house ~= nil then 
                N1Core.Functions.ExecuteSql(false, "SELECT * FROM `house_plants` WHERE plantid = '"..plantId.."' AND building = '"..house.."'", function(result)
                    if result[1] ~= nil then
                        Player.Functions.AddItem('weed_'..plantName..'_seed', amount)
                        Player.Functions.AddItem('weed_'..plantName, sndAmount)
                        Player.Functions.RemoveItem('empty_weed_bag', 1)
                        N1Core.Functions.ExecuteSql(true, "DELETE FROM `house_plants` WHERE plantid = '"..plantId.."' AND building = '"..house.."'")
                        TriggerClientEvent('N1Core:Notify', src, 'The plant is harvested', 'success', 3500)
                        TriggerClientEvent('N1-weed:client:refreshHousePlants', -1, house)
                    else
                        TriggerClientEvent('N1Core:Notify', src, 'This plant does not exist anymore', 'error', 3500)
                    end
                end)
            else
                TriggerClientEvent('N1Core:Notify', src, 'House not found', 'error', 3500)
            end
        else
            TriggerClientEvent('N1Core:Notify', src, 'You don\'t have enough bags', 'error', 3500)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'You don\'t have any bags', 'error', 3500)
    end
end)

RegisterServerEvent('N1-weed:server:foodPlant')
AddEventHandler('N1-weed:server:foodPlant', function(house, amount, plantName, plantId)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    N1Core.Functions.ExecuteSql(false, 'SELECT * FROM `house_plants` WHERE `building` = "'..house..'" AND `sort` = "'..plantName..'" AND `plantid` = "'..tostring(plantId)..'"', function(plantStats)
        TriggerClientEvent('N1Core:Notify', src, N1Weed.Plants[plantName]["label"]..' | Nutrition: '..plantStats[1].food..'% + '..amount..'% ('..(plantStats[1].food + amount)..'%)', 'success', 3500)
        if plantStats[1].food + amount > 100 then
            N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `food` = '100' WHERE `building` = '"..house.."' AND `plantid` = '"..plantId.."'")
        else
            N1Core.Functions.ExecuteSql(true, "UPDATE `house_plants` SET `food` = '"..(plantStats[1].food + amount).."' WHERE `building` = '"..house.."' AND `plantid` = '"..plantId.."'")
        end
        Player.Functions.RemoveItem('weed_nutrition', 1)
        TriggerClientEvent('N1-weed:client:refreshHousePlants', -1, house)
    end)
end)