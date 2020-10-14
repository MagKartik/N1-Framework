N1Core = {}
N1Core.Config = N1Config
N1Core.Shared = N1Shared
N1Core.ServerCallbacks = {}
N1Core.UseableItems = {}

function GetCoreObject()
	return N1Core
end

RegisterServerEvent('N1Core:GetObject')
AddEventHandler('N1Core:GetObject', function(cb)
	cb(GetCoreObject())
end)