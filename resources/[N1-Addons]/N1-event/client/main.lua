N1Core = nil

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if N1Core == nil then
            TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)
            Citizen.Wait(200)
        end
    end
end)

-- Code

local EventActive = false
local FrozenVeh = nil

RegisterNetEvent('N1-event:client:EventMovie')
AddEventHandler('N1-event:client:EventMovie', function()
    if not EventActive then
        SetNuiFocus(true, false)
        SendNUIMessage({
            action = "enable"
        })

        if IsPedInAnyVehicle(GetPlayerPed(-1)) then
            FrozenVeh = GetVehiclePedIsIn(GetPlayerPed(-1))
            FreezeEntityPosition(FrozenVeh, true)
        end
        EventActive = true
    end
end)

RegisterNUICallback('CloseEvent', function(data, cb)
    SetNuiFocus(false, false)
    EventActive = false
    FreezeEntityPosition(FrozenVeh, false)
    FrozenVeh = nil
end)