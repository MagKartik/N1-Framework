N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

local doorInfo = {}

RegisterServerEvent('N1-doorlock:server:setupDoors')
AddEventHandler('N1-doorlock:server:setupDoors', function()
	local src = source
	TriggerClientEvent("N1-doorlock:client:setDoors", N1.Doors)
end)

RegisterServerEvent('N1-doorlock:server:updateState')
AddEventHandler('N1-doorlock:server:updateState', function(doorID, state)
	local src = source
	local Player = N1Core.Functions.GetPlayer(src)
	
	N1.Doors[doorID].locked = state

	TriggerClientEvent('N1-doorlock:client:setState', -1, doorID, state)
end)