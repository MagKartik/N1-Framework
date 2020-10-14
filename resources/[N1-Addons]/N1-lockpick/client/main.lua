N1Core = nil

Citizen.CreateThread(function()
	while N1Core == nil do
		TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)
		Citizen.Wait(0)
	end
end)

-- Code

AddEventHandler('N1-lockpick:client:openLockpick', function(callback)
    lockpickCallback = callback
    openLockpick(true)
end)

RegisterNUICallback('callback', function(data, cb)
    openLockpick(false)
	lockpickCallback(data.success)
    cb('ok')
end)

RegisterNUICallback('exit', function()
    openLockpick(false)
end)

openLockpick = function(bool)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        action = "ui",
        toggle = bool,
    })
    SetCursorLocation(0.5, 0.2)
    lockpicking = bool
end