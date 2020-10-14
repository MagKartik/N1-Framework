N1Core = nil
TriggerEvent('N1Core:GetObject', function(obj) N1Core = obj end)

Citizen.CreateThread(function()
    N1Core.Functions.ExecuteSql(false, "SELECT * FROM `companies`", function(result)
        if result[1] ~= nil then
            for k, v in pairs(result) do
                Config.Companies[v.name] = {
                    name = v.name,
                    label = v.label,
                    employees = v.employees ~= nil and json.decode(v.employees) or {},
                    owner = v.owner,
                    money = v.money,
                }
            end
        end
        TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
    end)
end)

RegisterServerEvent('N1-companies:server:loadCompanies')
AddEventHandler('N1-companies:server:loadCompanies', function()
    local src = source
    TriggerClientEvent("N1-companies:client:setCompanies", src, Config.Companies)
end)

RegisterServerEvent('N1-companies:server:createCompany')
AddEventHandler('N1-companies:server:createCompany', function(name)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local bankAmount = Player.PlayerData.money["bank"]
    local cashAmount = Player.PlayerData.money["cash"]
    if cashAmount >= Config.CompanyPrice or bankAmount >= Config.CompanyPrice then
        if name ~= nil then 
            local companyLabel = escapeSqli(name)
            local companyName = escapeSqli(name:gsub("%s+", ""):lower())
            if companyName ~= "" then
                if IsNameAvailable(companyName) then
                    if cashAmount >= Config.CompanyPrice then
                        Player.Functions.RemoveMoney("cash", Config.CompanyPrice, "company-created")
                        N1Core.Functions.ExecuteSql(false, "INSERT INTO `companies` (`name`, `label`, `owner`) VALUES ('"..companyName.."', '"..companyLabel.."', '"..Player.PlayerData.citizenid.."')")
                        Config.Companies[companyName] = {
                            name = companyName,
                            label = name,
                            employees = {},
                            owner = Player.PlayerData.citizenid,
                            money = 0,
                        }
                        TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
                        TriggerClientEvent('N1Core:Notify', src, "Congratulations, you are the owner of: "..companyLabel)
                    else
                        Player.Functions.RemoveMoney("bank", Config.CompanyPrice, "company-created")
                        N1Core.Functions.ExecuteSql(false, "INSERT INTO `companies` (`name`, `label`, `owner`) VALUES ('"..companyName.."', '"..companyLabel.."', '"..Player.PlayerData.citizenid.."')")
                        Config.Companies[companyName] = {
                            name = companyName,
                            label = name,
                            employees = {},
                            owner = Player.PlayerData.citizenid,
                            money = 0,
                        }
                        TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
                        TriggerClientEvent('N1Core:Notify', src, "Congratulations, you are the owner of: "..companyLabel)
                    end
                else
                    TriggerClientEvent('N1Core:Notify', src, 'The name : ' .. companyLabel .. ' is already used..', 'error', 4000)
                end
            else
                TriggerClientEvent('N1Core:Notify', src, 'Name cannot be empty..', 'error', 4000)
            end
        else
            TriggerClientEvent('N1Core:Notify', src, 'Name cannot be empty..', 'error', 4000)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'You dont have enough money..', 'error', 4000)
    end
end)

RegisterServerEvent('N1-companies:server:removeCompany')
AddEventHandler('N1-companies:server:removeCompany', function(companyName)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if companyName ~= nil then 
        if IsCompanyOwner(companyName, Player.PlayerData.citizenid) then
            companyLabel = Config.Companies[companyName].label
            N1Core.Functions.ExecuteSql(true, "DELETE FROM `companies` WHERE `name` = '"..escapeSqli(companyName).."'")
            Config.Companies[companyName] = nil
            TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
            TriggerClientEvent("N1-phone:client:setupCompanies", src)
            TriggerClientEvent("N1-phone:client:InPhoneNotify", src, "Companies", "success", "You deleted " .. companyLabel .. " !")
        else
            TriggerClientEvent('N1Core:Notify', src, 'You are not the owner of this company..', 'error', 4000)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'Name cannot be empty..', 'error', 4000)
    end
end)

RegisterServerEvent('N1-companies:server:quitCompany')
AddEventHandler('N1-companies:server:quitCompany', function(companyName)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    if companyName ~= nil then 
        if IsEmployee(companyName, Player.PlayerData.citizenid) then
            companyLabel = Config.Companies[companyName].label
            Config.Companies[companyName].employees[Player.PlayerData.citizenid] = nil

            TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
            TriggerClientEvent("N1-phone:client:setupCompanies", src)
            TriggerClientEvent("N1-phone:client:InPhoneNotify", src, "Companies", "success", "You resigned from" .. companyLabel .. "!")

            local updatedEmployees = {}
            for employee, info in pairs(Config.Companies[companyName].employees) do
                updatedEmployees[employee] = info
            end
            N1Core.Functions.ExecuteSql(false, "UPDATE `companies` SET `employees` = '"..json.encode(updatedEmployees).."' WHERE `name` = '"..escapeSqli(companyName).."'")
        else
            TriggerClientEvent('N1Core:Notify', src, 'You are not the owner of this company..', 'error', 4000)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'Name cannot be empty..', 'error', 4000)
    end
end)

RegisterServerEvent('N1-companies:server:addEmployee')
AddEventHandler('N1-companies:server:addEmployee', function(playerCitizenId, companyName, rank)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local OtherPlayer = N1Core.Functions.GetPlayerByCitizenId(playerCitizenId)
    local rank = tonumber(rank)
    if OtherPlayer ~= nil then 
        if IsCompanyOwner(companyName, Player.PlayerData.citizenid) then
            if rank > 0 and rank < Config.MaxRank then
                Config.Companies[companyName].employees[OtherPlayer.PlayerData.citizenid] {
                    name = OtherPlayer.PlayerData.charinfo.firstname .. " " .. OtherPlayer.PlayerData.charinfo.lastname,
                    citizenid = OtherPlayer.PlayerData.citizenid,
                    rank = rank,
                }
                N1Core.Functions.ExecuteSql(false, "UPDATE `companies` SET `employees` = '"..json.encode(Config.Companies[companyName].employees).."' WHERE `name` = '"..escapeSqli(companyName).."'")
                TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
                TriggerClientEvent('N1Core:Notify', src, 'You added ' .. OtherPlayer.PlayerData.firstname .. ' ' .. OtherPlayer.PlayerData.lastname .. ' to the workers (rank: '..rank..')')
                TriggerClientEvent('N1Core:Notify', OtherPlayer.PlayerData.source, 'You have been added to company ' .. Config.Companies[companyName].label .. "(rank: " ..rank..")")
            else
                TriggerClientEvent('N1Core:Notify', src, 'Min rank is 1 and max rank is '..(Config.MaxRank-1)..'..', 'error', 4000)
            end
        else
            TriggerClientEvent('N1Core:Notify', src, 'You are not the owner of this company..', 'error', 4000)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'Person is not present..', 'error', 4000)
    end
end)

RegisterServerEvent('N1-companies:server:alterEmployee')
AddEventHandler('N1-companies:server:alterEmployee', function(playerCitizenId, companyName, isPromote)
    local src = source
    local Player = N1Core.Functions.GetPlayer(src)
    local otherCitizenId = playerCitizenId:upper()
    if CanAlterEmployee(companyName, Player.PlayerData.citizenid) then
        if Config.Companies[companyName].employees[otherCitizenId] ~= nil then 
            if isPromote then
                local newRank = Config.Companies[companyName].employees[otherCitizenId].rank + 1
                if newRank < Config.MaxRank then
                    Config.Companies[companyName].employees[otherCitizenId].rank = newRank
                    N1Core.Functions.ExecuteSql(false, "UPDATE `companies` SET `employees` = '"..json.encode(Config.Companies[companyName].employees).."' WHERE `name` = '"..escapeSqli(companyName).."'")
                    TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
                    TriggerClientEvent('N1Core:Notify', src, 'Worker rank updated to: ' ..newRank)
                else
                    TriggerClientEvent('N1Core:Notify', src, '"Person cannot be promoted..', 'error', 4000)
                end
            else
                local newRank = Config.Companies[companyName].employees[otherCitizenId].rank - 1
                if newRank > 0 then
                    Config.Companies[companyName].employees[otherCitizenId].rank = newRank
                    N1Core.Functions.ExecuteSql(false, "UPDATE `companies` SET `employees` = '"..json.encode(Config.Companies[companyName].employees).."' WHERE `name` = '"..escapeSqli(companyName).."'")
                    TriggerClientEvent("N1-companies:client:setCompanies", -1, Config.Companies)
                    TriggerClientEvent('N1Core:Notify', src, 'Worker rank updated to: ' ..newRank)
                else
                    TriggerClientEvent('N1Core:Notify', src, 'Person cannot be demoted..', 'error', 4000)
                end
            end
        else
            TriggerClientEvent('N1Core:Notify', src, 'Person is not an employee of your company..', 'error', 4000)
        end
    else
        TriggerClientEvent('N1Core:Notify', src, 'You are not the owner of this company..', 'error', 4000)
    end
end)

function IsEmployee(companyName, citizenid)
    local retval = false
    if Config.Companies[companyName] ~= nil then 
        if Config.Companies[companyName].employees ~= nil then 
            if Config.Companies[companyName].employees[citizenid] ~= nil then 
                retval = true
            elseif Config.Companies[companyName].owner == citizenid then
                retval = true
            end
        else
            if Config.Companies[companyName].owner == citizenid then
                retval = true
            end
        end
    end
    return retval
end

function CanAlterEmployee(companyName, citizenid)
    local retval = false
    if Config.Companies[companyName] ~= nil then 
        if Config.Companies[companyName].owner == citizenid then
            retval = true
        elseif Config.Companies[companyName].employees[citizenid] ~= nil then 
            if Config.Companies[companyName].employees[citizenid].rank == (Config.MaxRank - 1) then
                retval = true
            end
        end
    end
    return retval
end

function IsCompanyOwner(companyName, citizenid)
    local retval = false
    if Config.Companies[companyName] ~= nil then 
        if Config.Companies[companyName].owner == citizenid then
            retval = true
        end
    end
    return retval
end

function IsNameAvailable(name)
    local retval = false
    N1Core.Functions.ExecuteSql(true, "SELECT * FROM `companies` WHERE `name` = '"..name.."'", function(result)
        if result[1] ~= nil then 
            retval = false
        else
            retval = true
        end
    end)
    return retval
end

function escapeSqli(str)
    local replacements = { ['"'] = '\\"', ["'"] = "\\'" }
    return str:gsub( "['\"]", replacements ) -- or string.gsub( source, "['\"]", replacements )
end