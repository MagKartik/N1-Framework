-- Load N1Core and get permissions --
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

local group = Config.Group

-- Check if is decorating --

local IsDecorating = false

RegisterNetEvent('N1-anticheat:client:ToggleDecorate')
AddEventHandler('N1-anticheat:client:ToggleDecorate', function(bool)
  IsDecorating = bool
end)

-- Few frequently used locals --

local flags = 0 
local player = PlayerId()
local ped = GetPlayerPed(-1)

local isLoggedIn = false

RegisterNetEvent('N1Core:Client:OnPlayerLoaded')
AddEventHandler('N1Core:Client:OnPlayerLoaded', function()
    N1Core.Functions.TriggerCallback('N1-anticheat:server:GetPermissions', function(UserGroup)
        group = UserGroup
    end)
    isLoggedIn = true
end)

-- Superjump --

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(500)
 
        local ped = GetPlayerPed(-1)
        local pedId = PlayerPedId()

        if group == Config.Group and isLoggedIn then 
            if IsPedJumping(pedId) then
                local firstCoord = GetEntityCoords(ped)
  
                while IsPedJumping(pedId) do
                    Citizen.Wait(0)
                end
        
                local secondCoord = GetEntityCoords(ped)
                local lengthBetweenCoords = GetDistanceBetweenCoords(firstCoord, secondCoord, false)

                if (lengthBetweenCoords > Config.SuperJumpLength) then
                    flags = flags + 1      
                    TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Superjump)**")         
                end
            end
        end
    end
end)

-- Speedhack --

Citizen.CreateThread(function()
	while true do
        Citizen.Wait(500)

        local ped = GetPlayerPed(-1)
        local speed = GetEntitySpeed(ped) 
        local inveh = IsPedInAnyVehicle(ped, false)
        local ragdoll = IsPedRagdoll(ped)
        local jumping = IsPedJumping(ped)
        local falling = IsPedFalling(ped)
 
        if group == Config.Group and isLoggedIn then 
            if not inveh then
                if not ragdoll then 
                    if not falling then 
                        if not jumping then 
                            if speed > Config.MaxSpeed then 
                                flags = flags + 1 
                                TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Speedhack)**")   
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- Invisibility --

Citizen.CreateThread(function()
    while true do      
        Citizen.Wait(10000)

        local ped = GetPlayerPed(-1)

        if group == Config.Group and isLoggedIn then 
            if not IsDecorating then 
                if not IsEntityVisible(ped) then
                    SetEntityVisible(ped, 1, 0)
                    TriggerEvent('N1Core:Notify', "N1-ANTICHEAT: You were invisble but now visible again!")
                    TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Made player visible", "green", "** @everyone " ..GetPlayerName(player).. "** was invisible and is visible again by the N1-Anticheat")            
                end 
            end
        end
    end
end)

-- Nightvision --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        local ped = GetPlayerPed(-1)

        if group == Config.Group and isLoggedIn then 
            if GetUsingnightvision(true) then 
                if not IsPedInAnyHeli(ped) then
                    flags = flags + 1 
                    TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Nightvision)**")
                end
            end
        end
    end
end)

-- Thermalvision --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)

        local ped = GetPlayerPed(-1)

        if group == Config.Group and isLoggedIn then 
            if GetUsingseethrough(true) then 
                if not IsPedInAnyHeli(ped) then
                    flags = flags + 1
                    TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Cheat detected!", "orange", "** @everyone " ..GetPlayerName(player).. "** has been flagged by the anticheat! **(Flag "..flags.." /"..Config.FlagsForBan.." | Thermalvision)**") 
                end
            end
        end
    end
end)

-- Spawned car --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        local ped = GetPlayerPed(-1)
        local veh = GetVehiclePedIsIn(ped)
        local DriverSeat = GetPedInVehicleSeat(veh, -1)
        local plate = GetVehicleNumberPlateText(veh)

        if isLoggedIn then
            if group == Config.Group then
                if IsPedInAnyVehicle(ped, true) then
                    for _, BlockedPlate in pairs(Config.BlacklistedPlates) do
                        if plate == BlockedPlate then
                            if DriverSeat == ped then 
                                DeleteVehicle(veh)               
                                TriggerServerEvent("N1-anticheat:server:banPlayer", "Cheating")
                                TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Cheat detected!", "red", "** @everyone " ..GetPlayerName(player).. "** has been banned for cheating (Was in a spawned vehicle with the lincense plate **"..BlockedPlate.."**")         
                            end   
                        end
                    end
                end
            end
        end
    end
end)

-- Check if ped has weapon in inventory --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)

        if isLoggedIn then

            local PlayerPed = GetPlayerPed(-1)
            local CurrentWeapon = GetSelectedPedWeapon(PlayerPed)
            local WeaponInformation = N1Core.Shared.Weapons[CurrentWeapon]

            if WeaponInformation["name"] ~= "weapon_unarmed" then
                N1Core.Functions.TriggerCallback('N1-anticheat:server:HasWeaponInInventory', function(HasWeapon)
                    if not HasWeapon then
                        RemoveAllPedWeapons(PlayerPed, false)
                        TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Weapon deleted!", "orange", "** @everyone " ..GetPlayerName(player).. "** had a weapon on him that he didnt had in his inventory. N1 Anticheat deleted the weapon.")  
                    end
                end, WeaponInformation)
            end

        end
    end
end)

-- Max flags reached = ban, log, explosion & break --

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        local coords = GetEntityCoords(ped, true)
        
        if flags >= Config.FlagsForBan then
            -- TriggerServerEvent("N1-anticheat:server:banPlayer", "Cheating")
            -- AddExplosion(coords, EXPLOSION_GRENADE, 1000.0, true, false, false, true)
            TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Player banned! (Test)", "red", "** @everyone " ..GetPlayerName(player).. "** has been flagged to much and has been banned!")  
            flags = 0 
        end
    end
end)

RegisterNetEvent('N1-anticheat:client:NonRegisteredEventCalled')
AddEventHandler('N1-anticheat:client:NonRegisteredEventCalled', function(reason, CalledEvent)
    local player = PlayerId()
    local ped = GetPlayerPed(-1)

    TriggerServerEvent('N1-anticheat:server:banPlayer', reason)
    TriggerServerEvent("N1-log:server:CreateLog", "anticheat", "Player banned! (Test)", "red", "** @everyone " ..GetPlayerName(player).. "** has tried to trigger event **"..CalledEvent.." (LUA injector!)")  
end)