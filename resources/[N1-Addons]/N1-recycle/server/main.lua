N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local ItemTable = {
    "metalscrap",
    "plastic",
    "copper",
    "iron",
    "aluminum",
    "steel",
    "glass",
}

RegisterServerEvent("N1-recycle:server:getItem")
AddEventHandler("N1-recycle:server:getItem", function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    for i = 1, math.random(1, 5), 1 do
        local randItem = ItemTable[math.random(1, #ItemTable)]
        local amount = math.random(2, 6)
        Player.Functions.AddItem(randItem, amount)
        TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items[randItem], 'add')
        Citizen.Wait(500)
    end

    local Luck = math.random(1, 10)
    local Odd = math.random(1, 10)
    if Luck == Odd then
        local random = math.random(1, 3)
        Player.Functions.AddItem("rubber", random)
        TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["rubber"], 'add')
    end
end)