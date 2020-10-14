N1Core = {}
N1Core.PlayerData = {}
N1Core.Config = N1Config
N1Core.Shared = N1Shared
N1Core.ServerCallbacks = {}

isLoggedIn = false

function GetCoreObject()
	return N1Core
end

RegisterNetEvent('N1Core:GetObject')
AddEventHandler('N1Core:GetObject', function(cb)
	cb(GetCoreObject())
end)

RegisterNetEvent('N1Core:Client:OnPlayerLoaded')
AddEventHandler('N1Core:Client:OnPlayerLoaded', function()
	ShutdownLoadingScreenNui()
	isLoggedIn = true
end)

RegisterNetEvent('N1Core:Client:OnPlayerUnload')
AddEventHandler('N1Core:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)
