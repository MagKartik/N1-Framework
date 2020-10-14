N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

RegisterNetEvent('N1-policealerts:server:AddPoliceAlert')
AddEventHandler('N1-policealerts:server:AddPoliceAlert', function(data, forBoth)
    forBoth = forBoth ~= nil and forBoth or false
    TriggerClientEvent('N1-policealerts:client:AddPoliceAlert', -1, data, forBoth)
end)