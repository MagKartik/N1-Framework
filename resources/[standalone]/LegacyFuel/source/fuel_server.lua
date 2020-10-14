N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

function round(value, numDecimalPlaces)
	return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", value))
end

RegisterServerEvent('fuel:pay')
AddEventHandler('fuel:pay', function(price)
	local src = source
	local pData = N1Core.Functions.GetPlayer(src)
	local amount = round(price)

	if pData.Functions.RemoveMoney('cash', amount, "bought-fuel") then
		TriggerClientEvent("N1Core:Notify", src, "Your vehicle has been refilled", "success")
	end
end)
