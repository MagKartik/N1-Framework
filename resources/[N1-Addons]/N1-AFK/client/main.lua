-- AFK Kick Time Limit (in seconds)
secondsUntilKick = 1800

-- Load N1Core
N1Core = nil

Citizen.CreateThread(function() 
    while true do
        Citizen.Wait(1)
        if N1Core == nil then
            TriggerEvent("N1Core:GetObject", function(obj) N1Core = obj end)    
            Citizen.Wait(200)
        end
    end
end)

local group = "user"
local isLoggedIn = false

RegisterNetEvent('N1Core:Client:OnPlayerLoaded')
AddEventHandler('N1Core:Client:OnPlayerLoaded', function()
    N1Core.Functions.TriggerCallback('N1-afkkick:server:GetPermissions', function(UserGroup)
        group = UserGroup
    end)
    isLoggedIn = true
end)

RegisterNetEvent('N1Core:Client:OnPermissionUpdate')
AddEventHandler('N1Core:Client:OnPermissionUpdate', function(UserGroup)
    group = UserGroup
end)

-- Code
Citizen.CreateThread(function()
	while true do
		Wait(1000)
        playerPed = GetPlayerPed(-1)
        if isLoggedIn then
            if group == "user" then
                currentPos = GetEntityCoords(playerPed, true)
                if prevPos ~= nil then
                    if currentPos == prevPos then
                        if time ~= nil then
                            if time > 0 then
                                if time == (900) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)
                                elseif time == (600) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)
                                elseif time == (300) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)
                                elseif time == (150) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minutes!', 'error', 10000)   
                                elseif time == (60) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. math.ceil(time / 60) .. ' minute!', 'error', 10000) 
                                elseif time == (30) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. time .. ' seconds!', 'error', 10000)  
                                elseif time == (20) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. time .. ' seconds!', 'error', 10000)    
                                elseif time == (10) then
                                    N1Core.Functions.Notify('You are AFK and will be kicked in ' .. time .. ' seconds!', 'error', 10000)                                                                                                            
                                end
                                time = time - 1
                            else
                                TriggerServerEvent("KickForAFK")
                            end
                        else
                            time = secondsUntilKick
                        end
                    else
                        time = secondsUntilKick
                    end
                end
                prevPos = currentPos
            end
        end
    end
end)