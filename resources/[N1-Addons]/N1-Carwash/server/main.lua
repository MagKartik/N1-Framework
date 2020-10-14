N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

RegisterServerEvent('N1-carwash:server:washCar')
AddEventHandler('N1-carwash:server:washCar', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if Player.Functions.RemoveMoney('cash', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('N1-carwash:client:washCar', src)
    elseif Player.Functions.RemoveMoney('bank', Config.DefaultPrice, "car-washed") then
        TriggerClientEvent('N1-carwash:client:washCar', src)
    else
        TriggerClientEvent('N1Core:Notify', src, 'You dont have enough money..', 'error')
    end
end)