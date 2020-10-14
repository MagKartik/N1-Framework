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

isLoggedIn = true

RegisterNetEvent('N1Core:Client:OnPlayerLoaded')
AddEventHandler('N1Core:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

function DrawText3D(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end