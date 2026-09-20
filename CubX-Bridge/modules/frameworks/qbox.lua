--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local QBoxFramework = {}
local eventHandlers = {}
local QBoxObject = nil

function QBoxFramework.Initialize()
    if GetResourceState("qbx_core") ~= "started" then
        CBUX.Utils.Error("QBox (qbx_core) resource not started!")
        return false
    end
    QBoxObject = exports.qbx_core
    CBUX.FrameworkObject = QBoxObject
    CBUX.Utils.Debug("QBox initialized successfully")
    
    if not IsDuplicityVersion() then
        if lib then
            lib.loadModule("playerdata")
        end
    end
    
    QBoxFramework.SetupEventProxies()
    return true
end

function QBoxFramework.SetupEventProxies()
    if IsDuplicityVersion() then
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Server:PlayerLoaded", function(Player)
            local source = Player.PlayerData.source
            local wrappedPlayer = QBoxFramework.WrapPlayer(Player)
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
            local convertedJob = QBoxFramework.ConvertJob(job)
            TriggerEvent(Config.EventPrefix .. ":server:jobUpdated", source, convertedJob)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Server:OnGangUpdate", function(source, gang)
            local convertedGang = QBoxFramework.ConvertGang(gang)
            TriggerEvent(Config.EventPrefix .. ":server:gangUpdated", source, convertedGang)
        end)
    else
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
            local pData = QBoxFramework.GetPlayerData()
            TriggerEvent(Config.EventPrefix .. ":client:playerLoaded", pData)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
            local convertedJob = QBoxFramework.ConvertJob(job)
            if CBUX.PlayerData then
                CBUX.PlayerData.job = convertedJob
            end
            TriggerEvent(Config.EventPrefix .. ":client:jobUpdated", convertedJob)
        end)
        
        eventHandlers[#eventHandlers + 1] = AddEventHandler("QBCore:Client:OnGangUpdate", function(gang)
            local convertedGang = QBoxFramework.ConvertGang(gang)
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

function QBoxFramework.ConvertJob(jobData)
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

function QBoxFramework.ConvertGang(gangData)
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

function QBoxFramework.ConvertPlayerData(playerData)
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
        job = QBoxFramework.ConvertJob(playerData.job),
        gang = QBoxFramework.ConvertGang(playerData.gang),
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

function QBoxFramework.WrapPlayer(qbxPlayer)
    if not qbxPlayer then return nil end
    
    local wrapped = QBoxFramework.ConvertPlayerData(qbxPlayer.PlayerData)
    wrapped._qbxPlayer = qbxPlayer
    
    function wrapped.AddMoney(self, moneyType, amount, reason)
        local success = qbxPlayer.Functions.AddMoney(moneyType, amount, reason)
        if success and self.money then
            self.money[moneyType] = (self.money[moneyType] or 0) + amount
        end
        return success
    end
    
    function wrapped.RemoveMoney(self, moneyType, amount, reason)
        local success = qbxPlayer.Functions.RemoveMoney(moneyType, amount, reason)
        if success and self.money then
            self.money[moneyType] = (self.money[moneyType] or 0) - amount
        end
        return success
    end
    
    function wrapped.SetMoney(self, moneyType, amount, reason)
        local success = qbxPlayer.Functions.SetMoney(moneyType, amount, reason)
        if success and self.money then
            self.money[moneyType] = amount
        end
        return success
    end
    
    function wrapped.GetMoney(self, moneyType)
        return qbxPlayer.Functions.GetMoney(moneyType)
    end
    
    function wrapped.SetJob(self, jobName, grade)
        return qbxPlayer.Functions.SetJob(jobName, tonumber(grade) or 0)
    end
    
    function wrapped.SetGang(self, gangName, grade)
        return qbxPlayer.Functions.SetGang(gangName, tonumber(grade) or 0)
    end
    
    function wrapped.SetMetadata(self, key, value)
        qbxPlayer.Functions.SetMetaData(key, value)
        if self.metadata then
            self.metadata[key] = value
        end
        return true
    end
    
    function wrapped.GetMetadata(self, key)
        if key then
            return qbxPlayer.Functions.GetMetaData(key)
        end
        return qbxPlayer.PlayerData.metadata
    end
    
    function wrapped.Notify(self, message, type, duration)
        TriggerClientEvent("ox_lib:notify", self.source, {
            title = "Notification",
            description = message,
            type = type or "inform",
            duration = duration or Config.Notifications.defaultDuration
        })
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
        return exports.ox_inventory:GetItemCount(self.source, item) >= (amount or 1)
    end
    
    return wrapped
end

if IsDuplicityVersion() then
    function QBoxFramework.GetPlayer(source)
        local qbxPlayer = exports.qbx_core:GetPlayer(source)
        if not qbxPlayer then return nil end
        
        if CBUX.Players[source] then
            CBUX.Players[source]._qbxPlayer = qbxPlayer
            return CBUX.Players[source]
        end
        
        local wrapped = QBoxFramework.WrapPlayer(qbxPlayer)
        CBUX.Players[source] = wrapped
        return wrapped
    end
    
    function QBoxFramework.GetPlayerByIdentifier(identifier)
        local qbxPlayer = exports.qbx_core:GetPlayerByCitizenId(identifier)
        if not qbxPlayer then return nil end
        return QBoxFramework.WrapPlayer(qbxPlayer)
    end
    
    function QBoxFramework.GetPlayers()
        local players = {}
        for _, source in ipairs(GetPlayers()) do
            local p = QBoxFramework.GetPlayer(tonumber(source))
            if p then
                players[#players + 1] = p
            end
        end
        return players
    end
    
    function QBoxFramework.CreateCallback(name, cb)
        if lib and lib.callback then
            lib.callback.register(name, function(source, ...)
                return cb(source, ...)
            end)
        else
            exports["qb-core"]:CreateCallback(name, function(source, cbFunc, ...)
                local result = cb(source, ...)
                cbFunc(result)
            end)
        end
    end
    
    function QBoxFramework.GetJobs()
        return exports.qbx_core:GetJobs()
    end
    
    function QBoxFramework.GetGangs()
        return exports.qbx_core:GetGangs()
    end
    
    function QBoxFramework.DoesJobExist(jobName, grade)
        local jobs = exports.qbx_core:GetJobs()
        local job = jobs[jobName]
        if not job then return false end
        
        if grade then
            return job.grades[grade] ~= nil
        end
        return true
    end
else
    function QBoxFramework.GetPlayerData()
        local pData = nil
        if QBX and QBX.PlayerData then
            pData = QBX.PlayerData
        elseif lib and lib.callback then
            pData = lib.callback.await("qbx_core:getPlayerData")
        end
        
        if not pData or not pData.citizenid then return nil end
        
        if CBUX.PlayerData and CBUX.PlayerData.identifier == pData.citizenid then
            return CBUX.PlayerData
        end
        
        CBUX.PlayerData = QBoxFramework.ConvertPlayerData(pData)
        return CBUX.PlayerData
    end
    
    function QBoxFramework.TriggerCallback(name, cb, ...)
        if lib and lib.callback then
            lib.callback(name, false, cb, ...)
        else
            exports["qb-core"]:TriggerCallback(name, cb, ...)
        end
    end
    
    function QBoxFramework.IsPlayerLoaded()
        if QBX and QBX.PlayerData then
            return QBX.PlayerData.citizenid ~= nil
        end
        return false
    end
    
    function QBoxFramework.HasItem(item, amount)
        return exports.ox_inventory:GetItemCount(item) >= (amount or 1)
    end
end

CBUX.RegisterModule("frameworks", "qbox", QBoxFramework)