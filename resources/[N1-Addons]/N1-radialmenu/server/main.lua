RegisterServerEvent('json:dataStructure')
AddEventHandler('json:dataStructure', function(data)
    print(json.encode(data))
end)

RegisterServerEvent('N1-radialmenu:trunk:server:Door')
AddEventHandler('N1-radialmenu:trunk:server:Door', function(open, plate, door)
    TriggerClientEvent('N1-radialmenu:trunk:client:Door', -1, plate, door, open)
end)