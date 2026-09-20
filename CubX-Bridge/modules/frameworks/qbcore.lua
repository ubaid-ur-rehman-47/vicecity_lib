--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local QBCoreObject = nil
local QBCoreFramework = {}
local eventHandlers = {}

function QBCoreFramework.Initialize()
    if GetResourceState("qb-core") ~= "started" then
        CBUX.Utils.Error("QB-Core resource not started!")
        return false
    end
    QBCoreObject = exports["qb-core"]:GetCoreObject()
    if not QBCoreObject then
        CBUX.Utils.Error("Failed to get QBCore object!")
        return false
    end
    CBUX.FrameworkObject = QBCoreObject
    CBUX.Utils.Debug("QB-Core initialized successfully")
    QBCoreFramework.SetupEventProxies()
    return true
end

function QBCoreFramework.SetupEventProxies()
    if IsDuplicityVersion() then
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Server:PlayerLoaded", function(Player)
            local source = Player.PlayerData.source
            local wrappedPlayer = QBCoreFramework.WrapPlayer(Player)
            CBUX.Players[source] = wrappedPlayer
            TriggerEvent(Config.EventPrefix .. ":server:playerLoaded", source, wrappedPlayer)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Server:OnPlayerUnload", function(source)
            TriggerEvent(Config.EventPrefix .. ":server:playerDropped", source, "Unloaded")
            if CBUX.Players then
                CBUX.Players[source] = nil
            end
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("playerDropped", function(reason)
            local src = source
            TriggerEvent(Config.EventPrefix .. ":server:playerDropped", src, reason)
            if CBUX.Players then
                CBUX.Players[src] = nil
            end
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Server:OnJobUpdate", function(source, job)
            local convertedJob = QBCoreFramework.ConvertJob(job)
            TriggerEvent(Config.EventPrefix .. ":server:jobUpdated", source, convertedJob)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Server:OnGangUpdate", function(source, gang)
            local convertedGang = QBCoreFramework.ConvertGang(gang)
            TriggerEvent(Config.EventPrefix .. ":server:gangUpdated", source, convertedGang)
        end)
    else
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
            local pData = QBCoreFramework.GetPlayerData()
            TriggerEvent(Config.EventPrefix .. ":client:playerLoaded", pData)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
            local convertedJob = QBCoreFramework.ConvertJob(job)
            if CBUX.PlayerData then
                CBUX.PlayerData.job = convertedJob
            end
            TriggerEvent(Config.EventPrefix .. ":client:jobUpdated", convertedJob)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnGangUpdate", function(gang)
            local convertedGang = QBCoreFramework.ConvertGang(gang)
            if CBUX.PlayerData then
                CBUX.PlayerData.gang = convertedGang
            end
            TriggerEvent(Config.EventPrefix .. ":client:gangUpdated", convertedGang)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnMoneyChange", function(moneyType, amount, operation, reason)
            if CBUX.PlayerData and CBUX.PlayerData.money then
                local currentAmount = CBUX.PlayerData.money[moneyType] or 0
                if operation == "add" then
                    currentAmount = currentAmount + amount
                else
                    currentAmount = currentAmount - amount
                end
                
                CBUX.PlayerData.money[moneyType] = currentAmount
                
                local diff = amount
                if operation ~= "add" then
                    diff = -amount
                end
                
                TriggerEvent(Config.EventPrefix .. ":client:moneyUpdated", moneyType, currentAmount, diff)
            end
        end)
    end
end

function QBCoreFramework.ConvertJob(jobData)
    if not jobData then return nil end
    local job = {
        name = jobData.name,
        label = jobData.label,
        grade = jobData.grade and jobData.grade.level or 0,
        gradeLabel = jobData.grade and jobData.grade.name or "",
        salary = jobData.payment or 0,
        onDuty = jobData.onduty ~= false,
        isBoss = jobData.isboss or false
    }
    return job
end

function QBCoreFramework.ConvertGang(gangData)
    if not gangData then return nil end
    local gang = {
        name = gangData.name,
        label = gangData.label,
        grade = gangData.grade and gangData.grade.level or 0,
        gradeLabel = gangData.grade and gangData.grade.name or "",
        isBoss = gangData.isboss or false
    }
    return gang
end

function QBCoreFramework.ConvertPlayerData(playerData)
    if not playerData then return nil end
    
    local charinfo = playerData.charinfo or {}
    local metadata = playerData.metadata or {}
    local money = playerData.money or {}
    
    local pData = {
        source = playerData.source,
        identifier = playerData.citizenid,
        charinfo = {
            firstname = charinfo.firstname or "Unknown",
            lastname = charinfo.lastname or "Player",
            birthdate = charinfo.birthdate or "1990-01-01",
            gender = charinfo.gender or 0,
            nationality = charinfo.nationality or "Unknown",
            phone = charinfo.phone or nil
        },
        job = QBCoreFramework.ConvertJob(playerData.job),
        gang = QBCoreFramework.ConvertGang(playerData.gang),
        money = {
            cash = money.cash or 0,
            bank = money.bank or 0,
            crypto = money.crypto or 0
        },
        metadata = CBUX.Utils.MergeTables(Config.DefaultMetadata, metadata)
    }
    
    pData.name = pData.charinfo.firstname .. " " .. pData.charinfo.lastname
    pData.firstname = pData.charinfo.firstname
    pData.lastname = pData.charinfo.lastname
    
    return pData
end

function QBCoreFramework.WrapPlayer(qbPlayer)
    if not qbPlayer then return nil end
    
    local wrapped = QBCoreFramework.ConvertPlayerData(qbPlayer.PlayerData)
    wrapped._qbPlayer = qbPlayer
    
    function wrapped.AddMoney(self, moneyType, amount, reason)
        local success = qbPlayer.Functions.AddMoney(moneyType, amount, reason)
        if success and self.money then
            self.money[moneyType] = (self.money[moneyType] or 0) + amount
        end
        return success
    end
    
    function wrapped.RemoveMoney(self, moneyType, amount, reason)
        local success = qbPlayer.Functions.RemoveMoney(moneyType, amount, reason)
        if success and self.money then
            self.money[moneyType] = (self.money[moneyType] or 0) - amount
        end
        return success
    end
    
    function wrapped.SetMoney(self, moneyType, amount, reason)
        local success = qbPlayer.Functions.SetMoney(moneyType, amount, reason)
        if success and self.money then
            self.money[moneyType] = amount
        end
        return success
    end
    
    function wrapped.GetMoney(self, moneyType)
        return qbPlayer.Functions.GetMoney(moneyType)
    end
    
    function wrapped.SetJob(self, jobName, grade)
        return qbPlayer.Functions.SetJob(jobName, tonumber(grade) or 0)
    end
    
    function wrapped.SetGang(self, gangName, grade)
        return qbPlayer.Functions.SetGang(gangName, tonumber(grade) or 0)
    end
    
    function wrapped.SetMetadata(self, key, value)
        qbPlayer.Functions.SetMetaData(key, value)
        if self.metadata then
            self.metadata[key] = value
        end
        return true
    end
    
    function wrapped.GetMetadata(self, key)
        if key then
            return qbPlayer.Functions.GetMetaData(key)
        end
        return qbPlayer.PlayerData.metadata
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
            TriggerClientEvent("QBCore:Notify", self.source, message, type or "primary", duration or Config.Notifications.defaultDuration)
        end
    end
    
    function wrapped.Kick(self, reason)
        DropPlayer(self.source, reason or "You have been kicked from the server")
    end
    
    function wrapped.GetCoords(self)
        local ped = GetPlayerPed(self.source)
        return GetEntityCoords(ped)
    end
    
    function wrapped.SetCoords(self, coords)
        local ped = GetPlayerPed(self.source)
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end
    
    function wrapped.HasItem(self, item, amount)
        return qbPlayer.Functions.HasItem(item, amount)
    end
    
    return wrapped
end

if IsDuplicityVersion() then
    function QBCoreFramework.GetPlayer(source)
        local qbPlayer = QBCoreObject.Functions.GetPlayer(source)
        if not qbPlayer then return nil end
        
        if CBUX.Players[source] then
            CBUX.Players[source]._qbPlayer = qbPlayer
            return CBUX.Players[source]
        end
        
        local wrapped = QBCoreFramework.WrapPlayer(qbPlayer)
        CBUX.Players[source] = wrapped
        return wrapped
    end
    
    function QBCoreFramework.GetPlayerByIdentifier(identifier)
        local qbPlayer = QBCoreObject.Functions.GetPlayerByCitizenId(identifier)
        if not qbPlayer then return nil end
        return QBCoreFramework.WrapPlayer(qbPlayer)
    end
    
    function QBCoreFramework.GetPlayers()
        local players = {}
        for _, source in ipairs(QBCoreObject.Functions.GetPlayers()) do
            local p = QBCoreFramework.GetPlayer(source)
            if p then
                players[#players + 1] = p
            end
        end
        return players
    end
    
    function QBCoreFramework.CreateCallback(name, cb)
        QBCoreObject.Functions.CreateCallback(name, function(source, cbFunc, ...)
            local result = cb(source, ...)
            cbFunc(result)
        end)
    end
    
    function QBCoreFramework.GetJobs()
        return QBCoreObject.Shared.Jobs
    end
    
    function QBCoreFramework.GetGangs()
        return QBCoreObject.Shared.Gangs
    end
    
    function QBCoreFramework.DoesJobExist(jobName, grade)
        local job = QBCoreObject.Shared.Jobs[jobName]
        if not job then return false end
        
        if grade then
            return job.grades[tostring(grade)] ~= nil
        end
        return true
    end
else
    function QBCoreFramework.GetPlayerData()
        local pData = QBCoreObject.Functions.GetPlayerData()
        if not pData or not pData.citizenid then return nil end
        
        if CBUX.PlayerData and CBUX.PlayerData.identifier == pData.citizenid then
            return CBUX.PlayerData
        end
        
        CBUX.PlayerData = QBCoreFramework.ConvertPlayerData(pData)
        return CBUX.PlayerData
    end
    
    function QBCoreFramework.TriggerCallback(name, cb, ...)
        QBCoreObject.Functions.TriggerCallback(name, cb, ...)
    end
    
    function QBCoreFramework.IsPlayerLoaded()
        local pData = QBCoreObject.Functions.GetPlayerData()
        return pData and pData.citizenid ~= nil
    end
    
    function QBCoreFramework.HasItem(item, amount)
        return QBCoreObject.Functions.HasItem(item, amount)
    end
end

CBUX.RegisterModule("frameworks", "qbcore", QBCoreFramework)