N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

N1Core.Commands.Add("cash", "Kijk hoeveel geld je bij je hebt", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "cash")
end)

N1Core.Commands.Add("bank", "Kijk hoeveel geld je op je bank hebt", {}, false, function(source, args)
	TriggerClientEvent('hud:client:ShowMoney', source, "bank")
end)