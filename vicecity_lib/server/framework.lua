local function normalizeCharacter(data)
    local info = data and (data.charinfo or data)
    if not info then return nil end
    return {
        firstname = info.firstname or info.firstName,
        lastname = info.lastname or info.lastName,
        birthdate = info.birthdate or info.dateofbirth,
        gender = info.gender,
        nationality = info.nationality,
        phone = info.phone,
        citizenid = data.citizenid or data.identifier,
    }
end

local function normalizeJob(job)
    if not job then return nil end
    local grade = type(job.grade) == 'table' and job.grade or {}
    return {
        name = job.name,
        label = job.label,
        grade = tonumber(grade.level or job.grade) or 0,
        gradeLabel = grade.name or job.grade_label,
        onDuty = job.onduty == true or job.onDuty == true,
        isBoss = job.isboss == true or job.grade_name == 'boss',
    }
end

local function normalizeGang(gang)
    if not gang or not gang.name or gang.name == 'none' then return nil end
    local grade = type(gang.grade) == 'table' and gang.grade or {}
    return {
        name = gang.name,
        label = gang.label,
        grade = tonumber(grade.level or gang.grade) or 0,
        gradeLabel = grade.name or gang.grade_label,
        onDuty = gang.onduty == true or gang.onDuty == true,
        isBoss = gang.isboss == true or gang.grade_name == 'boss',
    }
end

local function createProvider(name, resource)
    return {
        name = name,
        resource = resource,
        capabilities = {
            player = true,
            character = true,
            job = true,
            gang = name ~= 'esx',
            accounts = name ~= 'standalone',
            metadata = name ~= 'standalone',
            permissions = name ~= 'standalone',
        },
    }
end

local standalone = createProvider('standalone')
function standalone:getPlayer() return nil end

function standalone:getPlayers() return GetPlayers() end

function standalone:getPlayerByIdentifier(identifier)
    for _, source in ipairs(GetPlayers()) do
        local player = tonumber(source)
        if player then
            for _, value in ipairs(GetPlayerIdentifiers(player)) do
                if value == identifier or value == ('license:' .. identifier) then return player end
            end
        end
    end
end

function standalone:getIdentifier(source)
    for _, value in ipairs(GetPlayerIdentifiers(source)) do
        if value:sub(1, 8) == 'license:' then return value:sub(9) end
    end
end

function standalone:getName(source) return GetPlayerName(source) end

function standalone:getRawPlayer() return nil end

function standalone:hasPermission() return false end

local esx = createProvider('esx', 'es_extended')
local esxObject
function esx:object()
    if not esxObject then
        local ok, object = pcall(function() return exports.es_extended:getSharedObject() end)
        if ok then esxObject = object end
    end
    return esxObject
end

function esx:getRawPlayer(source) return self:object() and self:object().GetPlayerFromId(source) end

function esx:getPlayer(source)
    local player = self:getRawPlayer(source)
    if not player then return nil end
    local data = player.get and player.get('charinfo') or {}
    return {
        source = source,
        identifier = player.identifier,
        name = player.getName and player.getName() or GetPlayerName(source),
        character = normalizeCharacter(data),
        job = normalizeJob(player.job),
        gang = nil,
        accounts = self:getAccounts(source),
        metadata = {},
    }
end

function esx:getPlayers() return self:object() and self:object().GetPlayers() or {} end

function esx:getPlayerByIdentifier(identifier)
    local player = self:object() and self:object().GetPlayerFromIdentifier(identifier)
    return player and self:getPlayer(player.source)
end

function esx:getIdentifier(source)
    local player = self:getRawPlayer(source)
    return player and player.identifier
end

function esx:getName(source)
    local player = self:getRawPlayer(source)
    return player and player.getName() or GetPlayerName(source)
end

function esx:getAccounts(source)
    local player = self:getRawPlayer(source)
    local accounts = {}
    for _, account in pairs(player and player.getAccounts and player.getAccounts() or {}) do
        accounts[account.name == 'money' and 'cash' or account.name] = account.money or 0
    end
    return accounts
end

function esx:getBalance(source, account) return self:getAccounts(source)[account] or 0 end

function esx:addMoney(source, account, amount)
    local player = self:getRawPlayer(source)
    if not player then return false end
    player.addAccountMoney(account == 'cash' and 'money' or account, amount)
    return true
end

function esx:removeMoney(source, account, amount)
    local player = self:getRawPlayer(source)
    if not player then return false end
    player.removeAccountMoney(account == 'cash' and 'money' or account, amount)
    return true
end

function esx:hasPermission(source, permission)
    local player = self:getRawPlayer(source)
    return player and player.getGroup and player.getGroup() == permission or false
end

local function qbProvider(name, resource)
    local provider = createProvider(name, resource)
    local object
    function provider:object()
        if not object then
            local ok, value = pcall(function()
                if self.name == 'qbox' then return exports.qbx_core:GetCoreObject() end
                return exports['qb-core']:GetCoreObject()
            end)
            if ok then object = value end
        end
        return object
    end

    function provider:getRawPlayer(source)
        if self.name == 'qbox' then return exports.qbx_core:GetPlayer(source) end
        local core = self:object()
        return core and core.Functions.GetPlayer(source)
    end

    function provider:getPlayer(source)
        local player = self:getRawPlayer(source)
        local data = player and player.PlayerData
        if not data then return nil end
        return {
            source = data.source or source,
            identifier = data.citizenid,
            name = data.name,
            character = normalizeCharacter(data),
            job = normalizeJob(data.job),
            gang = normalizeGang(data.gang),
            accounts = data.money or {},
            metadata = data.metadata or {},
        }
    end

    function provider:getPlayers()
        if self.name == 'qbox' then return exports.qbx_core:GetQBPlayers() end
        local core = self:object()
        return core and core.Functions.GetQBPlayers() or {}
    end

    function provider:getPlayerByIdentifier(identifier)
        local player
        if self.name == 'qbox' then
            player = exports.qbx_core:GetPlayerByCitizenId(identifier)
        else
            player = self:object().Functions.GetPlayerByCitizenId(identifier)
        end
        return player and self:getPlayer(player.PlayerData.source)
    end

    function provider:getIdentifier(source)
        local player = self:getRawPlayer(source)
        return player and player.PlayerData.citizenid
    end

    function provider:getName(source)
        local data = self:getPlayer(source)
        return data and data.name or GetPlayerName(source)
    end

    function provider:getAccounts(source)
        local player = self:getPlayer(source)
        return player and player.accounts or {}
    end

    function provider:getBalance(source, account) return self:getAccounts(source)[account] or 0 end

    function provider:addMoney(source, account, amount)
        local player = self:getRawPlayer(source)
        return player and player.Functions.AddMoney(account, amount) == true or false
    end

    function provider:removeMoney(source, account, amount)
        local player = self:getRawPlayer(source)
        return player and player.Functions.RemoveMoney(account, amount) == true or false
    end

    function provider:hasPermission(source, permission)
        local player = self:getRawPlayer(source)
        if not player then return false end
        if self.name == 'qbox' then return IsPlayerAceAllowed(source, permission) end
        return player.Functions.HasPermission(permission) == true
    end

    return provider
end

ViceCity.RegisterProvider('framework', 'standalone', standalone)
ViceCity.RegisterProvider('framework', 'esx', esx)
ViceCity.RegisterProvider('framework', 'qb', qbProvider('qb', 'qb-core'))
ViceCity.RegisterProvider('framework', 'qbox', qbProvider('qbox', 'qbx_core'))
