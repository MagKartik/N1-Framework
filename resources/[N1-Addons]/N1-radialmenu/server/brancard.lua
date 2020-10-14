RegisterServerEvent('N1-radialmenu:server:RemoveBrancard')
AddEventHandler('N1-radialmenu:server:RemoveBrancard', function(PlayerPos, BrancardObject)
    TriggerClientEvent('N1-radialmenu:client:RemoveBrancardFromArea', -1, PlayerPos, BrancardObject)
end)

RegisterServerEvent('N1-radialmenu:Brancard:BusyCheck')
AddEventHandler('N1-radialmenu:Brancard:BusyCheck', function(id, type)
    local MyId = source
    TriggerClientEvent('N1-radialmenu:Brancard:client:BusyCheck', id, MyId, type)
end)

RegisterServerEvent('N1-radialmenu:server:BusyResult')
AddEventHandler('N1-radialmenu:server:BusyResult', function(IsBusy, OtherId, type)
    TriggerClientEvent('N1-radialmenu:client:Result', OtherId, IsBusy, type)
end)