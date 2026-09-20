--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local ESXObject = nil
local ESXFramework = {}
local eventHandlers = {}

function ESXFramework.Initialize()
    if GetResourceState("es_extended") ~= "started" then
        CBUX.Utils.Error("ESX resource not started!")
        return false
    end
    ESXObject = exports.es_extended:getSharedObject()
    if not ESXObject then
        CBUX.Utils.Error("Failed to get ESX object!")
        return false
    end
    CBUX.FrameworkObject = ESXObject
    CBUX.Utils.Debug("ESX initialized successfully")
    ESXFramework.SetupEventProxies()
    return true
end

function ESXFramework.SetupEventProxies()
    if IsDuplicityVersion() then
        eventHandlers[#eventHandlers + 1] = AddEventHandler("esx:playerLoaded", function(source, xPlayer, isNew)
            local wrappedPlayer = ESXFramework.WrapPlayer(xPlayer)
            TriggerEvent(Config.EventPrefix .. ":server:playerLoaded", source, wrappedPlayer)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("esx:playerDropped", function(source, reason)
            TriggerEvent(Config.EventPrefix .. ":server:playerDropped", source, reason)
            if CBUX.Players then
                CBUX.Players[source] = nil
            end
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("esx:setJob", function(source, job, lastJob)
            local convertedJob = ESXFramework.ConvertJob(job)
            TriggerEvent(Config.EventPrefix .. ":server:jobUpdated", source, convertedJob)
            TriggerClientEvent(Config.EventPrefix .. ":client:jobUpdated", source, convertedJob)
        end)
    else
        eventHandlers[#eventHandlers + 1] = AddEventHandler("esx:playerLoaded", function(xPlayer, isNew, skin)
            local convertedData = ESXFramework.ConvertPlayerData(xPlayer)
            CBUX.PlayerData = convertedData
            TriggerEvent(Config.EventPrefix .. ":client:playerLoaded", convertedData)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("esx:setJob", function(job)
            local convertedJob = ESXFramework.ConvertJob(job)
            if CBUX.PlayerData then
                CBUX.PlayerData.job = convertedJob
            end
            TriggerEvent(Config.EventPrefix .. ":client:jobUpdated", convertedJob)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("esx:setAccountMoney", function(account)
            if CBUX.PlayerData then
                local unifiedType = ESXFramework.GetUnifiedMoneyType(account.name)
                if unifiedType and CBUX.PlayerData.money then
                    local oldAmount = CBUX.PlayerData.money[unifiedType] or 0
                    CBUX.PlayerData.money[unifiedType] = account.money
                    TriggerEvent(Config.EventPrefix .. ":client:moneyUpdated", unifiedType, account.money, account.money - oldAmount)
                end
            end
        end)
    end
end

function ESXFramework.GetUnifiedMoneyType(esxType)
    for unifiedType, cfg in pairs(Config.MoneyTypes) do
        if cfg.esx == esxType then
            return unifiedType
        end
    end
    return nil
end

function ESXFramework.GetESXAccountName(unifiedType)
    if Config.MoneyTypes[unifiedType] then
        return Config.MoneyTypes[unifiedType].esx
    end
    return unifiedType
end

function ESXFramework.ConvertJob(jobData)
    if not jobData then return nil end
    local job = {
        name = jobData.name,
        label = jobData.label,
        grade = tonumber(jobData.grade) or 0,
        gradeLabel = jobData.grade_label or jobData.grade_name or "",
        salary = jobData.grade_salary or 0,
        onDuty = true,
        isBoss = (jobData.grade_name == "boss" or jobData.isboss)
    }
    return job
end

function ESXFramework.ConvertPlayerData(playerData)
    if not playerData then return nil end
    
    local accountsData = playerData.accounts or {}
    local money = {
        cash = 0,
        bank = 0,
        crypto = 0
    }
    
    for _, acc in pairs(accountsData) do
        local unifiedType = ESXFramework.GetUnifiedMoneyType(acc.name)
        if unifiedType then
            money[unifiedType] = acc.money or 0
        end
    end
    
    local meta = playerData.metadata or {}
    local pData = {
        source = playerData.source,
        identifier = playerData.identifier,
        charinfo = {
            firstname = (playerData.variables and playerData.variables.firstName) or meta.firstName or "Unknown",
            lastname = (playerData.variables and playerData.variables.lastName) or meta.lastName or "Player",
            birthdate = meta.dateofbirth or "1990-01-01",
            gender = meta.sex or 0,
            nationality = meta.nationality or "Unknown",
            phone = meta.phone_number or nil
        },
        job = ESXFramework.ConvertJob(playerData.job),
        gang = nil,
        money = money,
        metadata = CBUX.Utils.MergeTables(Config.DefaultMetadata, meta)
    }
    
    pData.name = pData.charinfo.firstname .. " " .. pData.charinfo.lastname
    pData.firstname = pData.charinfo.firstname
    pData.lastname = pData.charinfo.lastname
    
    return pData
end

function ESXFramework.WrapPlayer(xPlayer)
    if not xPlayer then return nil end
    
    local wrapped = ESXFramework.ConvertPlayerData(xPlayer)
    wrapped._xPlayer = xPlayer
    
    function wrapped.AddMoney(self, moneyType, amount, reason)
        local esxAccount = ESXFramework.GetESXAccountName(moneyType)
        if esxAccount == "money" then
            xPlayer.addMoney(amount, reason)
        else
            xPlayer.addAccountMoney(esxAccount, amount, reason)
        end
        if self.money then
            self.money[moneyType] = (self.money[moneyType] or 0) + amount
        end
        return true
    end
    
    function wrapped.RemoveMoney(self, moneyType, amount, reason)
        local esxAccount = ESXFramework.GetESXAccountName(moneyType)
        local currentAmount = 0
        
        if esxAccount == "money" then
            currentAmount = xPlayer.getMoney()
        else
            local acc = xPlayer.getAccount(esxAccount)
            currentAmount = acc and acc.money or 0
        end
        
        if amount > currentAmount then
            return false
        end
        
        if esxAccount == "money" then
            xPlayer.removeMoney(amount, reason)
        else
            xPlayer.removeAccountMoney(esxAccount, amount, reason)
        end
        
        if self.money then
            self.money[moneyType] = (self.money[moneyType] or 0) - amount
        end
        return true
    end
    
    function wrapped.SetMoney(self, moneyType, amount, reason)
        local esxAccount = ESXFramework.GetESXAccountName(moneyType)
        if esxAccount == "money" then
            xPlayer.setMoney(amount)
        else
            xPlayer.setAccountMoney(esxAccount, amount, reason)
        end
        
        if self.money then
            self.money[moneyType] = amount
        end
        return true
    end
    
    function wrapped.GetMoney(self, moneyType)
        local esxAccount = ESXFramework.GetESXAccountName(moneyType)
        if esxAccount == "money" then
            return xPlayer.getMoney()
        else
            local acc = xPlayer.getAccount(esxAccount)
            return acc and acc.money or 0
        end
    end
    
    function wrapped.SetJob(self, jobName, grade)
        xPlayer.setJob(jobName, tonumber(grade) or 0)
        return true
    end
    
    function wrapped.SetGang(self, gangName, grade)
        if Config.GangSystem.enabled then
            CBUX.Utils.Warn("Gang system for ESX not yet implemented")
        end
        return false
    end
    
    function wrapped.SetMetadata(self, key, value)
        xPlayer.setMeta(key, value)
        if self.metadata then
            self.metadata[key] = value
        end
        return true
    end
    
    function wrapped.GetMetadata(self, key)
        if key then
            return xPlayer.getMeta(key)
        end
        return xPlayer.getMeta()
    end
    
    function wrapped.Notify(self, message, type, duration)
        if CBUX.HasOxLib then
            TriggerClientEvent("ox_lib:notify", self.source, {
                title = "Notification",
                description = message,
                type = type or "inform",
                duration = duration or Config.Notifications.defaultDuration
            })
        else
            xPlayer.triggerEvent("esx:showNotification", message)
        end
    end
    
    function wrapped.Kick(self, reason)
        xPlayer.kick(reason or "You have been kicked from the server")
    end
    
    function wrapped.GetCoords(self)
        return xPlayer.getCoords(true)
    end
    
    function wrapped.SetCoords(self, coords)
        xPlayer.setCoords(coords)
    end
    
    return wrapped
end

if IsDuplicityVersion() then
    function ESXFramework.GetPlayer(source)
        local xPlayer = ESXObject.GetPlayerFromId(source)
        if not xPlayer then return nil end
        
        if CBUX.Players[source] then
            CBUX.Players[source]._xPlayer = xPlayer
            return CBUX.Players[source]
        end
        
        local wrapped = ESXFramework.WrapPlayer(xPlayer)
        CBUX.Players[source] = wrapped
        return wrapped
    end
    
    function ESXFramework.GetPlayerByIdentifier(identifier)
        local xPlayer = ESXObject.GetPlayerFromIdentifier(identifier)
        if not xPlayer then return nil end
        return ESXFramework.WrapPlayer(xPlayer)
    end
    
    function ESXFramework.GetPlayers()
        local players = {}
        for _, xPlayer in pairs(ESXObject.GetExtendedPlayers()) do
            local p = ESXFramework.GetPlayer(xPlayer.source)
            if p then
                players[#players + 1] = p
            end
        end
        return players
    end
    
    function ESXFramework.CreateCallback(name, cb)
        ESXObject.RegisterServerCallback(name, function(source, cbFunc, ...)
            local result = cb(source, ...)
            cbFunc(result)
        end)
    end
    
    function ESXFramework.GetJobs()
        return ESXObject.GetJobs()
    end
    
    function ESXFramework.DoesJobExist(jobName, grade)
        return ESXObject.DoesJobExist(jobName, grade)
    end
else
    function ESXFramework.GetPlayerData()
        local pData = ESXObject.GetPlayerData()
        if not pData or not pData.job then return nil end
        
        if CBUX.PlayerData then
            return CBUX.PlayerData
        end
        
        CBUX.PlayerData = ESXFramework.ConvertPlayerData(pData)
        return CBUX.PlayerData
    end
    
    function ESXFramework.TriggerCallback(name, cb, ...)
        ESXObject.TriggerServerCallback(name, cb, ...)
    end
    
    function ESXFramework.IsPlayerLoaded()
        local pData = ESXObject.GetPlayerData()
        return pData and pData.job ~= nil
    end
end

CBUX.RegisterModule("frameworks", "esx", ESXFramework)