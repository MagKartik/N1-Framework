N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

RegisterServerEvent("KickForAFK")
AddEventHandler("KickForAFK", function()
	DropPlayer(source, "You have been kicked for AFK.")
end)

N1Core.Functions.CreateCallback('N1-afkkick:server:GetPermissions', function(source, cb)
    local group = N1Core.Functions.GetPermission(source)
    cb(group)
end)