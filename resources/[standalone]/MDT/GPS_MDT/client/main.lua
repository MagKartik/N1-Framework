ESX                           = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

coordsx = 0
coordsy = 0
coordsz = 0


RegisterNetEvent("GMS:test")
AddEventHandler("GMS:test", function(copname, locX, locY, locZ, call)
	--Checks if the steamname of the cop is the same as the steam name of the client
	if GetPlayerName(PlayerId(source)) == tostring(copname) then

		if DoesBlipExist(DestinationBlip) then
			RemoveBlip(DestinationBlip)
		else
			Citizen.Wait(0)
		end
		--sets the waypoint to the location
		DestinationBlip = AddBlipForCoord(vector3(tonumber(locX), tonumber(locY), tonumber(locZ)))
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName('Destination')
		EndTextCommandSetBlipName(blip)
		SetBlipRoute(DestinationBlip, true)
		coordsx = locX
		coordsy = locY
		coordsz = locZ
		--sends a notification to the cop
		ESX.ShowAdvancedNotification('Databank Locatie','', call, 'CHAR_CALL911', 0)
		while true do
			if locX == nil or locY == nil or locZ == nil then
				Citizen.Wait(0)
				TriggerServerEvent("GMS:ERROR", "Location x, y or z is nil")
			else
				local playerCoords     = GetEntityCoords(GetPlayerPed(-1), false)
				local targetCoords     = vector3(tonumber(coordsx), tonumber(coordsy), tonumber(coordsz))
				local targetDistance   = Vdist(playerCoords, targetCoords)
				--local targetDistance   = #(playerCoords - targetCoords)
				Citizen.Wait(0)
				if targetDistance <= 40.0 then
					RemoveBlip(DestinationBlip)
				else
					--TriggerServerEvent("GMS:ERROR", "not within distance Distance: " .. tostring(targetDistance))
					Citizen.Wait(0)
				end
			end
		end
		--If it doesn't work or you only have x and y you can use the code below
		--SetWaypointOff()
		--SetNewWaypoint(locX,  locY)
	else
		Citizen.Wait(0)
	end
end)
