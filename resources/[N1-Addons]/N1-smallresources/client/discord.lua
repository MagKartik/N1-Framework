Citizen.CreateThread(function()
	while true do
        --This is the Application ID (Replace this with you own)
		SetDiscordAppId(764960416044154902)

        --Here you will have to put the image name for the "large" icon.
		SetDiscordRichPresenceAsset('server_logo')
        
        --(11-11-2018) New Natives:

        --Here you can add hover text for the "large" icon.
        SetDiscordRichPresenceAssetText('https://discord.gg/bC6pRUd')

        --It updates every one minute just in case.
		Citizen.Wait(60000)
	end
end)