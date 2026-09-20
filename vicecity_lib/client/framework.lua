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
            vehicleProperties = name ~= 'standalone',
        },
    }
end

local standalone = createProvider('standalone')
function standalone:isLoaded() return true end

function standalone:getPlayerData() return {} end

function standalone:getIdentifier()
    return GetPlayerIdentifiers(PlayerId())[1]
end

function standalone:getName() return GetPlayerName(PlayerId()) end

function standalone:getCharacter() return nil end

function standalone:getJob() return nil end

function standalone:getGang() return nil end

function standalone:getAccounts() return {} end

function standalone:getMetadata() return {} end

function standalone:getVehicleProperties() return nil end

function standalone:getRawObject() return nil end

local esx = createProvider('esx', 'es_extended')
local esxObject
function esx:object()
    if not esxObject then
        local ok, object = pcall(function() return exports.es_extended:getSharedObject() end)
        if ok then esxObject = object end
    end
    return esxObject
end

function esx:isLoaded() return self:object() and self:object().IsPlayerLoaded() == true end

function esx:getPlayerData() return self:object() and self:object().GetPlayerData() end

function esx:getIdentifier() return (self:getPlayerData() or {}).identifier end

function esx:getName()
    local data = self:getPlayerData() or {}
    return data.name or GetPlayerName(PlayerId())
end

function esx:getCharacter() return normalizeCharacter(self:getPlayerData()) end

function esx:getJob() return normalizeJob((self:getPlayerData() or {}).job) end

function esx:getGang() return nil end

function esx:getAccounts()
    local accounts, data = {}, self:getPlayerData() or {}
    for _, account in pairs(data.accounts or {}) do
        accounts[account.name == 'money' and 'cash' or account.name] = account.money or 0
    end
    return accounts
end

function esx:getBalance(account) return self:getAccounts()[account] or 0 end

function esx:getRawObject() return self:object() end

function esx:getVehicleProperties(vehicle)
    local object = self:object()
    return object and object.Game and object.Game.GetVehicleProperties(vehicle)
end

local function qbProvider(name, resource)
    local provider = createProvider(name, resource)
    local object
    function provider:object()
        if not object then
            local exportName = self.name == 'qbox' and 'qbx_core' or 'qb-core'
            local ok, value = pcall(function()
                if self.name == 'qbox' then return exports.qbx_core:GetCoreObject() end
                return exports['qb-core']:GetCoreObject()
            end)
            if ok then object = value end
        end
        return object
    end

    function provider:isLoaded()
        return LocalPlayer.state.isLoggedIn == true
    end

    function provider:getPlayerData()
        if self.name == 'qbox' then return exports.qbx_core:GetPlayerData() end
        local core = self:object()
        return core and core.Functions.GetPlayerData()
    end

    function provider:getIdentifier() return (self:getPlayerData() or {}).citizenid end

    function provider:getName()
        local info = (self:getPlayerData() or {}).charinfo or {}
        return ((info.firstname or '') .. ' ' .. (info.lastname or '')):gsub('^%s+', ''):gsub('%s+$', '')
    end

    function provider:getCharacter() return normalizeCharacter(self:getPlayerData()) end

    function provider:getJob() return normalizeJob((self:getPlayerData() or {}).job) end

    function provider:getGang() return normalizeGang((self:getPlayerData() or {}).gang) end

    function provider:getAccounts() return (self:getPlayerData() or {}).money or {} end

    function provider:getBalance(account) return self:getAccounts()[account] or 0 end

    function provider:getMetadata() return (self:getPlayerData() or {}).metadata or {} end

    function provider:getRawObject() return self:object() end

    function provider:getVehicleProperties(vehicle)
        if self.name == 'qbox' then
            local ox = rawget(_G, 'lib')
            return ox and ox.getVehicleProperties(vehicle)
        end
        local core = self:object()
        return core and core.Functions.GetVehicleProperties(vehicle)
    end

    return provider
end

ViceCity.RegisterProvider('framework', 'standalone', standalone)
ViceCity.RegisterProvider('framework', 'esx', esx)
ViceCity.RegisterProvider('framework', 'qb', qbProvider('qb', 'qb-core'))
ViceCity.RegisterProvider('framework', 'qbox', qbProvider('qbox', 'qbx_core'))
