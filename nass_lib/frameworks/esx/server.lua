if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()

nass.framework = "esx"

function nass.getPlayer(source)
    return ESX.GetPlayerFromId(source)
end

function nass.getPlayerFromIdentifer(identifier)
    return ESX.GetPlayerFromIdentifier(identifier)
end

function nass.getPlayerIdentifier(source)
    return nass.getPlayer(source).identifier
end

function nass.getPlayerJob(source)
    return nass.getPlayer(source).getJob()
end

AddEventHandler('esx:playerLoaded', function(source)
    TriggerEvent('nass_lib:playerJoined', source)
end)

AddEventHandler('esx:playerDropped', function(source)
    TriggerEvent('nass_lib:playerLeft', source)
end)

function nass.getPlayerNameOffline(identifier, full)
    local playerData = MySQL.query.await('SELECT * FROM users WHERE identifier = ?', {identifier})

    local first, last = playerData[1].firstname, playerData[1].lastname
    if full then
        return first .." ".. last
    end
    return first, last
end

function nass.getPlayerName(source, full)
    local player = nass.getPlayer(source)
    local first, last = player.get("firstName"), player.get("lastName")
    if full then
        return first .." ".. last
    end
    return first, last
end

function nass.removeMoney(source, amount, account)
    if account == nil then account = "money" end
    if account == "cash" then account = "money" end
    local player = nass.getPlayer(source)
    if Config.useCashAsItem and account ~= "bank" then
        return player.removeInventoryItem(account, amount)
    end
    return player.removeAccountMoney(account, amount)
end

function nass.addMoney(source, amount, account)
    if account == nil then account = "money" end
    if account == "cash" then account = "money" end
    local player = nass.getPlayer(source)
    if Config.useCashAsItem and account ~= "bank" then
        return player.addInventoryItem(account, amount)
    end
    return player.addAccountMoney(account, amount)
end

function nass.getMoney(source, account)
    if account == nil then account = "money" end
    if account == 'cash' then account = 'money' end
    local player = nass.getPlayer(source)
    if Config.useCashAsItem and account ~= "bank" then
        return player.getInventoryItem(account).count or 0
    end
    return player.getAccount(account).money
end

function nass.addMoneyOffline(identifier, amount, account)
    if account == nil then account = "money" end
    if account == 'cash' then account = 'money' end

    MySQL.query('SELECT JSON_EXTRACT(accounts, "$.'..account..'") AS money FROM users WHERE identifier =?', {identifier}, function(amt)
        local otherPlayerBalence = tonumber(amt[1].money)
        otherPlayerBalence = otherPlayerBalence + amount
        MySQL.update('UPDATE `users` SET `accounts` = JSON_SET(accounts, "$.'..account..'", ?) WHERE identifier =?', {otherPlayerBalence, identifier})
    end)
end

function nass.removeMoneyOffline(identifier, amount, account)
    if account == nil then account = "money" end
    if account == 'cash' then account = 'money' end

    MySQL.query('SELECT JSON_EXTRACT(accounts, "$.'..account..'") AS money FROM users WHERE identifier =?', {identifier}, function(amt)
        local otherPlayerBalence = tonumber(amt[1].money)
        otherPlayerBalence = otherPlayerBalence - amount
        MySQL.update('UPDATE `users` SET `accounts` = JSON_SET(accounts, "$.'..account..'", ?) WHERE identifier =?', {otherPlayerBalence, identifier})
    end)
end

function nass.getMoneyOffline(identifier, account)
    if account == nil then account = "money" end
    if account == 'cash' then account = 'money' end

    MySQL.query('SELECT JSON_EXTRACT(accounts, "$.'..account..'") AS money FROM users WHERE identifier =?', {identifier}, function(amt)
        return tonumber(amt[1].money)
    end)
end

function nass.registerItem(item, cb)
    ESX.RegisterUsableItem(item, cb)
end

function nass.hasItem(source, _item)
    local xPlayer = nass.getPlayer(source)
    local item = xPlayer.getInventoryItem(_item)
    return item?.amount or item?.count or 0
end

function nass.addItem(source, itemName, count)
    local xPlayer = nass.getPlayer(source)
    return xPlayer.addInventoryItem(itemName, count)
end

function nass.removeItem(source, item, count)
    local xPlayer = nass.getPlayer(source)
    xPlayer.removeInventoryItem(item, count)
end

function nass.getInventory(source)
    local xPlayer = nass.getPlayer(source)
    return xPlayer.getInventory()
end

function nass.addSocietyMoney(society, amount)
    if not string.match(society, "society_") then
        society = "society_"..society
    end

    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        account.addMoney(amount)
        return true
    end)
end

function nass.removeSocietyMoney(society, amount)
    if not string.match(society, "society_") then
        society = "society_"..society
    end

    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        if amount > 0 and account.money >= amount then
            account.removeMoney(amount)
            return true
        else
            return false
        end
    end)
end

function nass.getSocietyMoney(society)
    if not string.match(society, "society_") then
        society = "society_"..society
    end

    TriggerEvent('esx_addonaccount:getSharedAccount', society, function(account)
        return account?.money or 0
    end)
end

function nass.getPlayers()
    return ESX.GetExtendedPlayers()
end

function nass.getJobs()
    return ESX.GetJobs()
end

function nass.createJob (name, label, grades)
    ESX.CreateJob(name, label, grades)
end