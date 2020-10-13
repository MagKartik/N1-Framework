ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Url waar je de JSON heen stuurt.
local url = "http://gms.nrc-rp.nl/assets/Meldingen.json"
local lastid = 0
local error = 0
	print('GPS systeem opgestart.')

function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end


RegisterServerEvent("GMS:ERROR")
AddEventHandler("GMS:ERROR", function(msg)
	print(msg)
end)

function checkForUpdate()
	--Call to JSON file
    PerformHttpRequest(url, function(err, data, headers)

		--Decode JSON data
        local parsed = json.decode(data)
        local pdata = parsed[1]
		--Check if
		if pdata["locy"] ~= "" or pdata["locx"] ~= "" or pdata["locz"] ~= "" then
		local error = 0

		local id = tonumber(pdata["id"])

		if(id >= lastid + 1) then
			local locX = pdata["locx"]
			local locY = pdata["locy"]
			local locZ = pdata["locz"]
			local call = pdata["melding"]
			local copname = pdata["steamnaam"]
			--Send event to client script
			TriggerClientEvent('GMS:test', -1, copname, locX, locY, locZ, call)

			--Replace last id, with JSON request id
			lastid = tonumber(pdata["id"])
			--The console message\/
			print("\n" .."\n" .."\n" ..'--------------------------------------------------------------------')
			print('------------------ LOCATIE VERSTUREN NAAR EENHEID ------------------')
			print('--------------------------------------------------------------------')
			print('requestID: ' .. pdata['id'])
			print('GRIP: ' ..copname)
			print('MELDING: ' ..call)
			print('Z: ' ..locZ)
			print('X: ' ..locX)
			print('Y: ' ..locY)
			print('--------------------------------------------------------------------')
			print('-------------------            EINDE              ------------------')
			print('--------------------------------------------------------------------' .."\n" .."\n" .."\n")
			if error == 1 then
				error = 0;
			end
		--End of IF statement
		end


		--Else if location vars are empty
		else
			if error ~= 1 then
				error = 1;
			--End of IF statement
			end
		--End of IF statement
		end

	--Set refresh timer to (2 seconds)
	SetTimeout((2000), checkForUpdate)

	--end the contact with the json file
    end, "GET", "",  { ["Content-Type"] = 'application/json' })
	--End of function
end

--Runs the function
checkForUpdate();
