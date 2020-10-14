N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

N1Core.Commands.Add("setcryptoworth", "Set crypto worth", {{name="crypto", help="Name of the crypto"}, {name="Worth", help="New worth of the crypto currency"}}, false, function(source, args)
    local src = source
    local crypto = tostring(args[1])

    if crypto ~= nil then
        if Crypto.Worth[crypto] ~= nil then
            local NewWorth = math.ceil(tonumber(args[2]))
            
            if NewWorth ~= nil then
                local PercentageChange = math.ceil(((NewWorth - Crypto.Worth[crypto]) / Crypto.Worth[crypto]) * 100)
                local ChangeLabel = "+"
                if PercentageChange < 0 then
                    ChangeLabel = "-"
                    PercentageChange = (PercentageChange * -1)
                end
                if Crypto.Worth[crypto] == 0 then
                    PercentageChange = 0
                    ChangeLabel = ""
                end

                table.insert(Crypto.History[crypto], {
                    PreviousWorth = Crypto.Worth[crypto],
                    NewWorth = NewWorth
                })

                TriggerClientEvent('N1Core:Notify', src, "You set the worth of "..Crypto.Labels[crypto].." from: (₹"..Crypto.Worth[crypto].." to: ₹"..NewWorth..") ("..ChangeLabel.." "..PercentageChange.."%)")
                Crypto.Worth[crypto] = NewWorth
                TriggerClientEvent('N1-crypto:client:UpdateCryptoWorth', -1, crypto, NewWorth)
                N1Core.Functions.ExecuteSql(false, "UPDATE `crypto` SET `worth` = '"..NewWorth.."', `history` = '"..json.encode(Crypto.History[crypto]).."' WHERE `crypto` = '"..crypto.."'")
            else
                TriggerClientEvent('N1Core:Notify', src, "You have not given a new value.. Current worth: "..Crypto.Worth[crypto])
            end
        else
            TriggerClientEvent('N1Core:Notify', src, "This Crypto does not exist :(, available crypto: N1it")
        end
    else
        TriggerClientEvent('N1Core:Notify', src, "You didnt insert a Crypto, available crypto: N1it")
    end
end, "admin")

N1Core.Commands.Add("checkcryptoworth", "", {}, false, function(source, args)
    local src = source
    TriggerClientEvent('N1Core:Notify', src, "The N1it has a value of: ₹"..Crypto.Worth["N1it"])
end, "admin")

N1Core.Commands.Add("crypto", "", {}, false, function(source, args)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local MyPocket = math.ceil(Player.PlayerData.money.crypto * Crypto.Worth["N1it"])

    TriggerClientEvent('N1Core:Notify', src, "You have: "..Player.PlayerData.money.crypto.." N1it, with a worth of: ₹"..MyPocket..",-")
end, "admin")

RegisterServerEvent('N1-crypto:server:FetchWorth')
AddEventHandler('N1-crypto:server:FetchWorth', function()
    for name,_ in pairs(Crypto.Worth) do
        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `crypto` WHERE `crypto` = '"..name.."'", function(result)
            if result[1] ~= nil then
                Crypto.Worth[name] = result[1].worth
                if result[1].history ~= nil then
                    Crypto.History[name] = json.decode(result[1].history)
                    TriggerClientEvent('N1-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, json.decode(result[1].history))
                else
                    TriggerClientEvent('N1-crypto:client:UpdateCryptoWorth', -1, name, result[1].worth, nil)
                end
            end
        end)
    end
end)

RegisterServerEvent('N1-crypto:server:ExchangeFail')
AddEventHandler('N1-crypto:server:ExchangeFail', function()
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        Player.Functions.RemoveItem("cryptostick", 1)
        TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('N1Core:Notify', src, "Attempt failed, the stick crashed..", 'error', 5000)
    end
end)

RegisterServerEvent('N1-crypto:server:Rebooting')
AddEventHandler('N1-crypto:server:Rebooting', function(state, percentage)
    Crypto.Exchange.RebootInfo.state = state
    Crypto.Exchange.RebootInfo.percentage = percentage
end)

RegisterServerEvent('N1-crypto:server:GetRebootState')
AddEventHandler('N1-crypto:server:GetRebootState', function()
    local src = source
    TriggerClientEvent('N1-crypto:client:GetRebootState', src, Crypto.Exchange.RebootInfo)
end)

RegisterServerEvent('N1-crypto:server:SyncReboot')
AddEventHandler('N1-crypto:server:SyncReboot', function()
    TriggerClientEvent('N1-crypto:client:SyncReboot', -1)
end)

RegisterServerEvent('N1-crypto:server:ExchangeSuccess')
AddEventHandler('N1-crypto:server:ExchangeSuccess', function(LuckChance)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local ItemData = Player.Functions.GetItemByName("cryptostick")

    if ItemData ~= nil then
        local LuckyNumber = math.random(1, 10)
        local DeelNumber = 1000000
        local Amount = (math.random(611111, 1599999) / DeelNumber)
        if LuckChance == LuckyNumber then
            Amount = (math.random(1599999, 2599999) / DeelNumber)
        end

        Player.Functions.RemoveItem("cryptostick", 1)
        Player.Functions.AddMoney('crypto', Amount)
        TriggerClientEvent('N1Core:Notify', src, "You have exchanged your Cryptostick for: "..Amount.." N1it(\'s)", "success", 3500)
        TriggerClientEvent('inventory:client:ItemBox', src, N1Core.Shared.Items["cryptostick"], "remove")
        TriggerClientEvent('N1-phone_new:client:AddTransaction', src, Player, {}, "There are "..Amount.." N1it('s) credited!", "Bijschrijving")
    end
end)

N1Core.Functions.CreateCallback('N1-crypto:server:HasSticky', function(source, cb)
    local Player = N1Core.Functions.GetPlayer(source)
    local Item = Player.Functions.GetItemByName("cryptostick")

    if Item ~= nil then
        cb(true)
    else
        cb(false)
    end
end)

N1Core.Functions.CreateCallback('N1-crypto:server:GetCryptoData', function(source, cb, name)
    local Player = N1Core.Functions.GetPlayer(source)
    local CryptoData = {
        History = Crypto.History[name],
        Worth = Crypto.Worth[name],
        Portfolio = Player.PlayerData.money.crypto,
        WalletId = Player.PlayerData.metadata["walletid"],
    }

    cb(CryptoData)
end)

N1Core.Functions.CreateCallback('N1-crypto:server:BuyCrypto', function(source, cb, data)
    local Player = N1Core.Functions.GetPlayer(source)

    if Player.PlayerData.money.bank >= tonumber(data.Price) then
        local CryptoData = {
            History = Crypto.History["N1it"],
            Worth = Crypto.Worth["N1it"],
            Portfolio = Player.PlayerData.money.crypto + tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('bank', tonumber(data.Price))
        TriggerClientEvent('N1-phone_new:client:AddTransaction', source, Player, data, "You bought "..tonumber(data.Coins).." N1it('s)!", "Bijschrijving")
        Player.Functions.AddMoney('crypto', tonumber(data.Coins))
        cb(CryptoData)
    else
        cb(false)
    end
end)

N1Core.Functions.CreateCallback('N1-crypto:server:SellCrypto', function(source, cb, data)
    local Player = N1Core.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        local CryptoData = {
            History = Crypto.History["N1it"],
            Worth = Crypto.Worth["N1it"],
            Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
            WalletId = Player.PlayerData.metadata["walletid"],
        }
        Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
        TriggerClientEvent('N1-phone_new:client:AddTransaction', source, Player, data, "You sold "..tonumber(data.Coins).." N1it('s)!", "Afschrijving")
        Player.Functions.AddMoney('bank', tonumber(data.Price))
        cb(CryptoData)
    else
        cb(false)
    end
end)

N1Core.Functions.CreateCallback('N1-crypto:server:TransferCrypto', function(source, cb, data)
    local Player = N1Core.Functions.GetPlayer(source)

    if Player.PlayerData.money.crypto >= tonumber(data.Coins) then
        N1Core.Functions.ExecuteSql(false, "SELECT * FROM `players` WHERE `metadata` LIKE '%"..data.WalletId.."%'", function(result)
            if result[1] ~= nil then
                local CryptoData = {
                    History = Crypto.History["N1it"],
                    Worth = Crypto.Worth["N1it"],
                    Portfolio = Player.PlayerData.money.crypto - tonumber(data.Coins),
                    WalletId = Player.PlayerData.metadata["walletid"],
                }
                Player.Functions.RemoveMoney('crypto', tonumber(data.Coins))
                TriggerClientEvent('N1-phone_new:client:AddTransaction', source, Player, data, "You transfered "..tonumber(data.Coins).." N1it('s)!", "Afschrijving")
                local Target = N1Core.Functions.GetPlayerByCitizenId(result[1].citizenid)

                if Target ~= nil then
                    Target.Functions.AddMoney('crypto', tonumber(data.Coins))
                    TriggerClientEvent('N1-phone_new:client:AddTransaction', Target.PlayerData.source, Player, data, "There are "..tonumber(data.Coins).." N1it('s) credited!", "Bijschrijving")
                else
                    MoneyData = json.decode(result[1].money)
                    MoneyData.crypto = MoneyData.crypto + tonumber(data.Coins)
                    N1Core.Functions.ExecuteSql(false, "UPDATE `players` SET `money` = '"..json.encode(MoneyData).."' WHERE `citizenid` = '"..result[1].citizenid.."'")
                end
                cb(CryptoData)
            else
                cb("notvalid")
            end
        end)
    else
        cb("notenough")
    end
end)