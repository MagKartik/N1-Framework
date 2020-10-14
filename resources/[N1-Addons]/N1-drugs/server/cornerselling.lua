N1Core.Functions.CreateCallback('N1-drugs:server:cornerselling:getAvailableDrugs', function(source, cb)
    local AvailableDrugs = {}
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = N1Core.Shared.Items[item.name]["label"]
            })
        end
    end

    if next(AvailableDrugs) ~= nil then
        cb(AvailableDrugs)
    else
        cb(nil)
    end
end)

RegisterServerEvent('N1-drugs:server:sellCornerDrugs')
AddEventHandler('N1-drugs:server:sellCornerDrugs', function(item, amount, price)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local AvailableDrugs = {}

    Player.Functions.RemoveItem(item, amount)
    Player.Functions.AddMoney('cash', price, "sold-cornerdrugs")

    TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[item], "remove")

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = N1Core.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('N1-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)

RegisterServerEvent('N1-drugs:server:robCornerDrugs')
AddEventHandler('N1-drugs:server:robCornerDrugs', function(item, amount, price)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local AvailableDrugs = {}

    Player.Functions.RemoveItem(item, amount)

    TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[item], "remove")

    for i = 1, #Config.CornerSellingDrugsList, 1 do
        local item = Player.Functions.GetItemByName(Config.CornerSellingDrugsList[i])

        if item ~= nil then
            table.insert(AvailableDrugs, {
                item = item.name,
                amount = item.amount,
                label = N1Core.Shared.Items[item.name]["label"]
            })
        end
    end

    TriggerClientEvent('N1-drugs:client:refreshAvailableDrugs', src, AvailableDrugs)
end)