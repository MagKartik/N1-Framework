N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

RegisterServerEvent('N1-taxi:server:NpcPay')
AddEventHandler('N1-taxi:server:NpcPay', function(Payment)
    local fooikansasah = math.random(1, 5)
    local r1, r2 = math.random(1, 5), math.random(1, 5)

    if fooikansasah == r1 or fooikansasah == r2 then
        Payment = Payment + math.random(5, 10)
    end

    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    Player.Functions.AddMoney('cash', Payment)
end)