N1Core = nil

TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

--CODE

local Races = {}
RegisterServerEvent('N1-streetraces:NewRace')
AddEventHandler('N1-streetraces:NewRace', function(RaceTable)
    local src = source
    local RaceId = math.random(1000, 9999)
    local xPlayer = N1Core.Functions.GetPlayer(src)
    if xPlayer.Functions.RemoveMoney('cash', RaceTable.amount, "streetrace-created") then
        Races[RaceId] = RaceTable
        Races[RaceId].creator = GetPlayerIdentifiers(src)[1]
        table.insert(Races[RaceId].joined, GetPlayerIdentifiers(src)[1])
        TriggerClientEvent('N1-streetraces:SetRace', -1, Races)
        TriggerClientEvent('N1-streetraces:SetRaceId', src, RaceId)
        TriggerClientEvent('N1Core:Notify', src, "You joind the race for ₹"..Races[RaceId].amount..",-", 'success')
    end
end)

RegisterServerEvent('N1-streetraces:RaceWon')
AddEventHandler('N1-streetraces:RaceWon', function(RaceId)
    local src = source
    local xPlayer = N1Core.Functions.GetPlayer(src)
    xPlayer.Functions.AddMoney('cash', Races[RaceId].pot, "race-won")
    TriggerClientEvent('N1Core:Notify', src, "You won the race and ₹"..Races[RaceId].pot..",- recieved", 'success')
    TriggerClientEvent('N1-streetraces:SetRace', -1, Races)
    TriggerClientEvent('N1-streetraces:RaceDone', -1, RaceId, GetPlayerName(src))
end)

RegisterServerEvent('N1-streetraces:JoinRace')
AddEventHandler('N1-streetraces:JoinRace', function(RaceId)
    local src = source
    local xPlayer = N1Core.Functions.GetPlayer(src)
    local zPlayer = N1Core.Functions.GetPlayer(Races[RaceId].creator)
    if zPlayer ~= nil then
        if xPlayer.PlayerData.money.cash >= Races[RaceId].amount then
            Races[RaceId].pot = Races[RaceId].pot + Races[RaceId].amount
            table.insert(Races[RaceId].joined, GetPlayerIdentifiers(src)[1])
            if xPlayer.Functions.RemoveMoney('cash', Races[RaceId].amount, "streetrace-joined") then
                TriggerClientEvent('N1-streetraces:SetRace', -1, Races)
                TriggerClientEvent('N1-streetraces:SetRaceId', src, RaceId)
                TriggerClientEvent('N1Core:Notify', zPlayer.PlayerData.source, GetPlayerName(src).." Joined the race", 'primary')
            end
        else
            TriggerClientEvent('N1Core:Notify', src, "You dont have enough cash", 'error')
        end
    else
        TriggerClientEvent('N1Core:Notify', src, "The person wo made the race is offline!", 'error')
        Races[RaceId] = {}
    end
end)

N1Core.Commands.Add("race", "A street race has started.", {{name="bedrag", help="The stake amount for the race."}}, true, function(source, args)
    local src = source
    local xPlayer = N1Core.Functions.GetPlayer(src)
    local amount = tonumber(args[1])
    if GetJoinedRace(GetPlayerIdentifiers(src)[1]) == 0 then
        if xPlayer.PlayerData.money.cash >= amount then
            TriggerClientEvent('N1-streetraces:CreateRace', src, amount)
        else
            TriggerClientEvent('N1Core:Notify', src, "You don't have enough cash in your pocket", 'error')
        end
    else
        TriggerClientEvent('N1Core:Notify', src, "Your already in a race!", 'error')
    end
end)

N1Core.Commands.Add("stoprace", "Stop a race as creator.", {}, false, function(source, args)
    local src = source
    CancelRace(src)
end)

N1Core.Commands.Add("quitrace", "Quiting the race. (You wont get ur money back)", {}, false, function(source, args)
    local src = source
    local xPlayer = N1Core.Functions.GetPlayer(src)
    local RaceId = GetJoinedRace(GetPlayerIdentifiers(src)[1])
    local zPlayer = N1Core.Functions.GetPlayer(Races[RaceId].creator)
    if RaceId ~= 0 then
        if GetCreatedRace(GetPlayerIdentifiers(src)[1]) ~= RaceId then
            RemoveFromRace(GetPlayerIdentifiers(src)[1])
            TriggerClientEvent('N1Core:Notify', src, "You quited the race and wont get ur money back", 'error')
            TriggerClientEvent('esx:showNotification', zPlayer.PlayerData.source, GetPlayerName(src) .." has quited the race!", "red")
        else
            TriggerClientEvent('N1Core:Notify', src, "/stoprace to stop the race", 'error')
        end
    else
        TriggerClientEvent('N1Core:Notify', src, "Your not in a race.", 'error')
    end
end)

N1Core.Commands.Add("startrace", "Starting race", {}, false, function(source, args)
    local src = source
    local RaceId = GetCreatedRace(GetPlayerIdentifiers(src)[1])
    
    if RaceId ~= 0 then
        Races[RaceId].started = true
        TriggerClientEvent('N1-streetraces:SetRace', -1, Races)
        TriggerClientEvent("N1-streetraces:StartRace", -1, RaceId)
    else
        TriggerClientEvent('N1Core:Notify', src, "You did not start a race", 'error')
    end
end)

function CancelRace(source)
    local xPlayer = N1Core.Functions.GetPlayer(source)
    local RaceId = GetCreatedRace(GetPlayerIdentifiers(source)[1])

    if RaceId ~= 0 then
        for key, race in pairs(Races) do
            if Races[key] ~= nil and Races[key].creator == xPlayer.PlayerData.steam then
                if not Races[key].started then
                    for _, iden in pairs(Races[key].joined) do
                        local xdPlayer = N1Core.Functions.GetPlayer(iden)
                        xdPlayer.Functions.AddMoney('cash', Races[key].amount, "race-cancelled")
                        TriggerClientEvent('N1Core:Notify', xdPlayer.PlayerData.source, "The race has stopped you recieved ₹"..Races[key].amount..",-Back", 'error')
                        TriggerClientEvent('N1-streetraces:StopRace', xdPlayer.PlayerData.source)
                        RemoveFromRace(iden)
                    end
                else
                    TriggerClientEvent('N1Core:Notify', xPlayer.PlayerData.source, "The race has already started..", 'error')
                end
                TriggerClientEvent('N1Core:Notify', source, "Race has been stopped!", 'error')
                Races[key] = nil
            end
        end
        TriggerClientEvent('N1-streetraces:SetRace', -1, Races)
    else
        TriggerClientEvent('N1Core:Notify', source, "You did not start a race!", 'error')
    end
end

function RemoveFromRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for i, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    table.remove(Races[key].joined, i)
                end
            end
        end
    end
end

function GetJoinedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and not Races[key].started then
            for _, iden in pairs(Races[key].joined) do
                if iden == identifier then
                    return key
                end
            end
        end
    end
    return 0
end

function GetCreatedRace(identifier)
    for key, race in pairs(Races) do
        if Races[key] ~= nil and Races[key].creator == identifier and not Races[key].started then
            return key
        end
    end
    return 0
end
