-- N1Core Command Events
RegisterNetEvent('N1Core:Command:TeleportToPlayer')
AddEventHandler('N1Core:Command:TeleportToPlayer', function(othersource)
	local coords = N1Core.Functions.GetCoords(GetPlayerPed(GetPlayerFromServerId(othersource)))
	local entity = GetPlayerPed(-1)
	if IsPedInAnyVehicle(Entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, coords.x, coords.y, coords.z)
	SetEntityHeading(entity, coords.a)
end)

RegisterNetEvent('N1Core:Command:TeleportToCoords')
AddEventHandler('N1Core:Command:TeleportToCoords', function(x, y, z)
	local entity = GetPlayerPed(-1)
	if IsPedInAnyVehicle(Entity, false) then
		entity = GetVehiclePedIsUsing(entity)
	end
	SetEntityCoords(entity, x, y, z)
end)

RegisterNetEvent('N1Core:Command:SpawnVehicle')
AddEventHandler('N1Core:Command:SpawnVehicle', function(model)
	N1Core.Functions.SpawnVehicle(model, function(vehicle)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)
		TriggerEvent("vehiclekeys:client:SetOwner", GetVehicleNumberPlateText(vehicle))
	end)
end)

RegisterNetEvent('N1Core:Command:DeleteVehicle')
AddEventHandler('N1Core:Command:DeleteVehicle', function()
	local vehicle = N1Core.Functions.GetClosestVehicle()
	if IsPedInAnyVehicle(GetPlayerPed(-1)) then vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false) else vehicle = N1Core.Functions.GetClosestVehicle() end
	-- TriggerServerEvent('N1Core:Command:CheckOwnedVehicle', GetVehicleNumberPlateText(vehicle))
	N1Core.Functions.DeleteVehicle(vehicle)
end)

RegisterNetEvent('N1Core:Command:Revive')
AddEventHandler('N1Core:Command:Revive', function()
	local coords = N1Core.Functions.GetCoords(GetPlayerPed(-1))
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z+0.2, coords.a, true, false)
	SetPlayerInvincible(GetPlayerPed(-1), false)
	ClearPedBloodDamage(GetPlayerPed(-1))
end)

RegisterNetEvent('N1Core:Command:GoToMarker')
AddEventHandler('N1Core:Command:GoToMarker', function()
	Citizen.CreateThread(function()
		local entity = PlayerPedId()
		if IsPedInAnyVehicle(entity, false) then
			entity = GetVehiclePedIsUsing(entity)
		end
		local success = false
		local blipFound = false
		local blipIterator = GetBlipInfoIdIterator()
		local blip = GetFirstBlipInfoId(8)

		while DoesBlipExist(blip) do
			if GetBlipInfoIdType(blip) == 4 then
				cx, cy, cz = table.unpack(Citizen.InvokeNative(0xFA7C7F0AADF25D09, blip, Citizen.ReturnResultAnyway(), Citizen.ResultAsVector())) --GetBlipInfoIdCoord(blip)
				blipFound = true
				break
			end
			blip = GetNextBlipInfoId(blipIterator)
		end

		if blipFound then
			DoScreenFadeOut(250)
			while IsScreenFadedOut() do
				Citizen.Wait(250)
			end
			local groundFound = false
			local yaw = GetEntityHeading(entity)
			
			for i = 0, 1000, 1 do
				SetEntityCoordsNoOffset(entity, cx, cy, ToFloat(i), false, false, false)
				SetEntityRotation(entity, 0, 0, 0, 0 ,0)
				SetEntityHeading(entity, yaw)
				SetGameplayCamRelativeHeading(0)
				Citizen.Wait(0)
				--groundFound = true
				if GetGroundZFor_3dCoord(cx, cy, ToFloat(i), cz, false) then --GetGroundZFor3dCoord(cx, cy, i, 0, 0) GetGroundZFor_3dCoord(cx, cy, i)
					cz = ToFloat(i)
					groundFound = true
					break
				end
			end
			if not groundFound then
				cz = -300.0
			end
			success = true
		end

		if success then
			SetEntityCoordsNoOffset(entity, cx, cy, cz, false, false, true)
			SetGameplayCamRelativeHeading(0)
			if IsPedSittingInAnyVehicle(PlayerPedId()) then
				if GetPedInVehicleSeat(GetVehiclePedIsUsing(PlayerPedId()), -1) == PlayerPedId() then
					SetVehicleOnGroundProperly(GetVehiclePedIsUsing(PlayerPedId()))
				end
			end
			--HideLoadingPromt()
			DoScreenFadeIn(250)
		end
	end)
end)

-- Other stuff
RegisterNetEvent('N1Core:Player:SetPlayerData')
AddEventHandler('N1Core:Player:SetPlayerData', function(val)
	N1Core.PlayerData = val
end)

RegisterNetEvent('N1Core:Player:UpdatePlayerData')
AddEventHandler('N1Core:Player:UpdatePlayerData', function()
	local data = {}
	data.position = N1Core.Functions.GetCoords(GetPlayerPed(-1))
	TriggerServerEvent('N1Core:UpdatePlayer', data)
end)

RegisterNetEvent('N1Core:Player:UpdatePlayerPosition')
AddEventHandler('N1Core:Player:UpdatePlayerPosition', function()
	local position = N1Core.Functions.GetCoords(GetPlayerPed(-1))
	TriggerServerEvent('N1Core:UpdatePlayerPosition', position)
end)

RegisterNetEvent('N1Core:Client:LocalOutOfCharacter')
AddEventHandler('N1Core:Client:LocalOutOfCharacter', function(playerId, playerName, message)
	local sourcePos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(playerId)), false)
    local pos = GetEntityCoords(GetPlayerPed(-1), false)
    if (GetDistanceBetweenCoords(pos.x, pos.y, pos.z, sourcePos.x, sourcePos.y, sourcePos.z, true) < 20.0) then
		TriggerEvent("chatMessage", "OOC " .. playerName, "normal", message)
    end
end)

RegisterNetEvent('N1Core:Notify')
AddEventHandler('N1Core:Notify', function(text, type, length)
	N1Core.Functions.Notify(text, type, length)
end)

RegisterNetEvent('N1Core:Client:TriggerCallback')
AddEventHandler('N1Core:Client:TriggerCallback', function(name, ...)
	if N1Core.ServerCallbacks[name] ~= nil then
		N1Core.ServerCallbacks[name](...)
		N1Core.ServerCallbacks[name] = nil
	end
end)

RegisterNetEvent("N1Core:Client:UseItem")
AddEventHandler('N1Core:Client:UseItem', function(item)
	TriggerServerEvent("N1Core:Server:UseItem", item)
end)