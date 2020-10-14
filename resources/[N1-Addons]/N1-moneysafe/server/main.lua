N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

-- Code

Citizen.CreateThread(function()
    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes`", function(safes)
        if safes[1] ~= nil then
            for _, d in pairs(safes) do
                for safe, s in pairs(Config.Safes) do
                    if d.safe == safe then
                        Config.Safes[safe].money = d.money
                        d.transactions = json.decode(d.transactions)
                        if d.transactions ~= nil and next(d.transactions) ~= nil then
                            Config.Safes[safe].transactions = d.transactions
                        end
                        TriggerClientEvent('N1-moneysafe:client:UpdateSafe', -1, Config.Safes[safe], safe)
                    end
                end
            end
        end
    end)
end)

N1Core.Commands.Add("deposit", "Stop geld in de kluis", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    local amount = tonumber(args[1]) or 0

    TriggerClientEvent('N1-moneysafe:client:DepositMoney', source, amount)
end)

N1Core.Commands.Add("withdraw", "Take money out of safe", {}, false, function(source, args)
    local Player = N1Core.Functions.GetPlayer(source)
    local amount = tonumber(args[1]) or 0

    TriggerClientEvent('N1-moneysafe:client:WithdrawMoney', source, amount)
end)

function AddTransaction(safe, type, amount, Player, Automated)
    local cid = nil
    local name = nil
    local _source = nil
    if not Automated then
        local src = source
        local Player = N1Core.Functions.GetPlayer(src)
        cid = Player.PlayerData.citizenid
        name = Player.PlayerData.name
        _source = Player.PlayerData.source
    else
        cid = "LuaLeaks"
        name = "Fine\'s"
        _source = "Automatic"
    end
    table.insert(Config.Safes[safe].transactions, {
        type = type,
        amount = amount,
        safe = safe,
        citizenid = cid,
    })
    TriggerEvent("N1-log:server:sendLog", cid, type, {safe = safe, type = type, amount = amount, citizenid = cid})
    local label = "Withdrawed out"
    local color = "red"
    if type == "deposit" then
        label = "Deposited in"
        color = "green"
    end
	TriggerEvent("N1-log:server:CreateLog", "moneysafes", type, color, "**" .. name .. "** (citizenid: *" .. cid .. "* | id: *(" .. _source .. ")* has **₹" .. amount .. "** " .. label .. " the **" .. safe .. "** safe.")
end

RegisterServerEvent('N1-moneysafe:server:DepositMoney')
AddEventHandler('N1-moneysafe:server:DepositMoney', function(safe, amount, sender)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    
    if Player.PlayerData.money.cash >= amount then
        Player.Functions.RemoveMoney('cash', amount)
    elseif Player.PlayerData.money.bank >= amount then
        Player.Functions.RemoveMoney('bank', amount)
    else
        TriggerClientEvent('N1Core:Notify', src, "You don\'t have enough cash", "error")
        return
    end
    if sender == nil then
        AddTransaction(safe, "deposit", amount, Player, false)
    else
        AddTransaction(safe, "deposit", amount, {}, true)
    end
    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `moneysafes` WHERE `safe` = '"..safe.."'", function(result)
        if result[1] ~= nil then
            Config.Safes[safe].money = (Config.Safes[safe].money + amount)
            N1Core.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        else
            Config.Safes[safe].money = amount
            N1Core.Functions.ExecuteSql(false, "INSERT INTO `moneysafes` (`safe`, `money`, `transactions`) VALUES ('"..safe.."', '"..Config.Safes[safe].money.."', '"..json.encode(Config.Safes[safe].transactions).."')")
        end
        TriggerClientEvent('N1-moneysafe:client:UpdateSafe', -1, Config.Safes[safe], safe)
        TriggerClientEvent('N1Core:Notify', src, "You have put ₹"..amount..",- in the safe", "success")
    end)
end)

RegisterServerEvent('N1-moneysafe:server:WithdrawMoney')
AddEventHandler('N1-moneysafe:server:WithdrawMoney', function(safe, amount)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)

    if (Config.Safes[safe].money - amount) >= 0 then 
        AddTransaction(safe, "withdraw", amount, Player, false)
        Config.Safes[safe].money = (Config.Safes[safe].money - amount)
        N1Core.Functions.ExecuteSql(false, "UPDATE `moneysafes` SET money = '"..Config.Safes[safe].money.."', transactions = '"..json.encode(Config.Safes[safe].transactions).."' WHERE `safe` = '"..safe.."'")
        TriggerClientEvent('N1-moneysafe:client:UpdateSafe', -1, Config.Safes[safe], safe)
        TriggerClientEvent('N1Core:Notify', src, "You took ₹"..amount..",- out of the safe", "success")
        Player.Functions.AddMoney('cash', amount)
    else
        TriggerClientEvent('N1Core:Notify', src, "There is not enough money in the safe.", "error")
    end
end)