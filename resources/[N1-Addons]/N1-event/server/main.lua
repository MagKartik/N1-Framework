N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

N1Core.Commands.Add("eventmovie", "", {{name="toggle", help="Yes or No"}}, true, function(source, args)
	if args[1] == "Yes" then
		TriggerClientEvent("N1-event:client:EventMovie", -1)
		Wait(5000)
		TriggerEvent('N1-weathersync:server:setTime', 01, 00)
		TriggerEvent('N1-weathersync:server:setWeather', "thunder")
		exports['N1-weathersync']:ToggleBlackout()
		exports['N1-weathersync']:FreezeElement('time')
	elseif args[1] == "No" then
		TriggerEvent('N1-weathersync:server:setTime', 12, 00)
		TriggerEvent('N1-weathersync:server:setWeather', "extrasunny")
		exports['N1-weathersync']:ToggleBlackout()
		exports['N1-weathersync']:FreezeElement('time')
	end
end, 'admin')