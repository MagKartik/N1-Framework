N1Core.Functions.CreateUseableItem("joint", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseJoint", source)
    end
end)

N1Core.Functions.CreateUseableItem("armor", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseArmor", source)
end)

N1Core.Functions.CreateUseableItem("heavyarmor", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:UseHeavyArmor", source)
end)

-- N1Core.Functions.CreateUseableItem("smoketrailred", function(source, item)
--     local Player = N1Core.Functions.GetPlayer(source)
-- 	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
--         TriggerClientEvent("consumables:client:UseRedSmoke", source)
--     end
-- end)

N1Core.Functions.CreateUseableItem("parachute", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:UseParachute", source)
    end
end)

N1Core.Commands.Add("parachuteuit", "Doe je parachute uit", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
        TriggerClientEvent("consumables:client:ResetParachute", source)
end)

RegisterServerEvent("N1-smallpenis:server:AddParachute")
AddEventHandler("N1-smallpenis:server:AddParachute", function()
    local src = source
    local Ply = N1Core.Functions.GetPlayer(src)

    Ply.Functions.AddItem("parachute", 1)
end)

N1Core.Functions.CreateUseableItem("water_bottle", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("vodka", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

N1Core.Functions.CreateUseableItem("beer", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

N1Core.Functions.CreateUseableItem("whiskey", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:DrinkAlcohol", source, item.name)
end)

N1Core.Functions.CreateUseableItem("coffee", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("kurkakola", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Drink", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("sandwich", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("twerks_candy", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("snikkel_candy", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("tosti", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
	if Player.Functions.RemoveItem(item.name, 1, item.slot) then
        TriggerClientEvent("consumables:client:Eat", source, item.name)
    end
end)

N1Core.Functions.CreateUseableItem("binoculars", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("binoculars:Toggle", source)
end)

N1Core.Functions.CreateUseableItem("cokebaggy", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Cokebaggy", source)
end)

N1Core.Functions.CreateUseableItem("crack_baggy", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:Crackbaggy", source)
end)

N1Core.Functions.CreateUseableItem("xtcbaggy", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("consumables:client:EcstasyBaggy", source)
end)

N1Core.Functions.CreateUseableItem("firework1", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework")
end)

N1Core.Functions.CreateUseableItem("firework2", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_indep_firework_v2")
end)

N1Core.Functions.CreateUseableItem("firework3", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "proj_xmas_firework")
end)

N1Core.Functions.CreateUseableItem("firework4", function(source, item)
    local Player = N1Core.Functions.GetPlayer(source)
    TriggerClientEvent("fireworks:client:UseFirework", source, item.name, "scr_indep_fireworks")
end)

N1Core.Commands.Add("vestuit", "Doe je vest uit 4head", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    if Player.PlayerData.job.name == "police" then
        TriggerClientEvent("consumables:client:ResetArmor", source)
    else
        TriggerClientEvent('chatMessage', source, "SYSTEM", "error", "This command is for emergency services!")
    end
end)