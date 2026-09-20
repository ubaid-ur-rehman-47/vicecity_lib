if Cfg.Framework ~= 'qbcore' then return end

QBCore = nil
local SharedVehicles = {}
local SharedJobs = {}
local SharedGangs = {}
local CharacterNames = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

-- Initialize the framework object
pcall(function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

if not QBCore then
    TriggerEvent('QBCore:GetObject', function(obj)
        QBCore = obj
    end)
end

function HasFrameworkLoaded()
    return QBCore ~= nil
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           PLAYER DROP                            │
-- └──────────────────────────────────────────────────────────────────┘

if GetCurrentResourceName() == 'cd_bridge' then
    RegisterServerEvent('QBCore:Server:OnPlayerUnload', function(src)
        if not src then return end
        TriggerEvent('cd_bridge:PlayerDropped', src, 'logout')
    end)

    RegisterServerEvent('QBCore:Server:PlayerDropped', function(playerData)
        if not playerData then return end

        local src = nil
        if type(playerData) == 'number' then
            src = playerData
        elseif type(playerData) == 'table' and playerData.source then
            src = playerData.source
        end

        if not src then return end

        TriggerEvent('cd_bridge:PlayerDropped', src, 'dropped')
    end)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              PLAYER                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the player object
function GetPlayer(source)
    if not source then return end

    return QBCore.Functions.GetPlayer(source)
end

-- Get the unique identifier of a player
function GetIdentifier(source)
    local Player = GetPlayer(source)
    if not Player then return end

    return Player.PlayerData.citizenid
end

-- Get the source from a unique identifier
function GetSourceFromIdentifier(identifier)
    local players = QBCore.Functions.GetPlayers()
    for _, src in pairs(players) do
        src = tonumber(src)
        local Player = GetPlayer(src)
        if Player and Player.PlayerData.citizenid == identifier then
            return src
        end
    end
end

-- Get a players character name
function GetCharacterName(source)
    if CharacterNames[source] then
        return CharacterNames[source]
    end

    local Player = GetPlayer(source)
    if not Player then return end

    local char_name = CapitalizeWords(Player.PlayerData.charinfo.firstname..' '..Player.PlayerData.charinfo.lastname) or Locale('unknown')
    CharacterNames[source] = char_name
    return char_name
end

function BanPlayer(source, reason)
    reason = reason or 'No reason specified'

    DropPlayer(source, reason)
    MySQL.insert('INSERT INTO bans (name, license, discord, ip, reason, expire, bannedby) VALUES (?, ?, ?, ?, ?, ?, ?)', {
        GetPlayerName(source),
        QBCore.Functions.GetIdentifier(source, 'license'),
        QBCore.Functions.GetIdentifier(source, 'discord'),
        QBCore.Functions.GetIdentifier(source, 'ip'),
        reason,
        2147483647,
        'cd_bridge'
    })
    TriggerEvent('qb-log:server:CreateLog', 'cd_bridge', 'Player Banned', 'red', string.format('%s was banned by %s for %s', GetPlayerName(source), 'cd_bridge', reason), true)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               PERMS                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the admin permissions/group of a player
function GetAdminPerms(source)
    local Player = GetPlayer(source)
    if not Player then return end

    return QBCore.Functions.GetPermission(source)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the job name of a player
function GetJobName(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.name
end

-- Get the job label of a player
function GetJobLabel(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.label
end

-- Get the job grade of a player
function GetJobGrade(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.grade.level
end

-- Get the job label of a player
function GetJobGradeLabel(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.grade.name
end

-- Check if a player is on duty
function GetJobDuty(source)
    if Cfg.DisableDuty then
        return true
    end

    local customDuty = GetCustomJobDuty(source)
    if customDuty ~= nil then
        return customDuty
    end

    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.PlayerData.job.onduty
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                GANG                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the gang name of the player
function GetGangName(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.name
    end

    local Player = GetPlayer(source)
    if not Player then return end
    return Player.PlayerData.gang.name
end

-- Get the gang label of the player
function GetGangLabel(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.label
    end

    local Player = GetPlayer(source)
    if not Player then return end
    return Player.PlayerData.gang.label
end

-- Get the gang grade of the player
function GetGangGrade(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.grade
    end

    local Player = GetPlayer(source)
    if not Player then return end
    return Player.PlayerData.gang.grade.level
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               MONEY                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the amount of money a player has
function GetPlayerMoney(source, money_type)
    local Player = GetPlayer(source)
    if not Player then return end

    if money_type == 'bank' then
        return Player.PlayerData.money['bank']

    elseif money_type == 'cash' then
        return Player.PlayerData.money['cash']
    end
end

-- Add money to a player
function AddPlayerMoney(source, amount, money_type, reason)
    local Player = GetPlayer(source)
    if not Player then return end
    reason = reason or ''

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'deposit')
    end

    if money_type == 'bank' then
        Player.Functions.AddMoney('bank', amount, reason)

    elseif money_type == 'cash' then
        Player.Functions.AddMoney('cash', amount, reason)
    end
end

-- Remove money from a player
function RemovePlayerMoney(source, amount, money_type, reason)
    local Player = GetPlayer(source)
    if not Player then return end
    if amount <= 0 then return end
    reason = reason or ''

    local balance = GetPlayerMoney(source, money_type)
    if balance < amount then
        return false
    end

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'withdraw')
    end

    if money_type == 'bank' then
        Player.Functions.RemoveMoney('bank', amount, reason)
        return true

    elseif money_type == 'cash' then
        Player.Functions.RemoveMoney('cash', amount, reason)
        return true
    end
end

-- Add money to an offline player
function AddMoneyToOfflinePlayer(identifier, amount, money_type, reason)
    local accountName

    if money_type == 'bank' then
        accountName = 'bank'
    elseif money_type == 'cash' then
        accountName = 'cash'
    else
        return
    end

    local row = DB.single('SELECT money FROM players WHERE citizenid = ? LIMIT 1', {identifier})
    if not row then return end

    local money = {}
    if row.money and row.money ~= '' then
        local success, decoded = pcall(json.decode, row.money)
        if success and type(decoded) == 'table' then
            money = decoded
        end
    end

    money[accountName] = (tonumber(money[accountName]) or 0) + tonumber(amount)

    DB.exec('UPDATE players SET money = ? WHERE citizenid = ?', {json.encode(money), identifier})
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               ITEMS                              │
-- └──────────────────────────────────────────────────────────────────┘

function RegisterUsableItem(item_name, onUse)
    QBCore.Functions.CreateUseableItem(item_name, function(source, item)
        if onUse then
            onUse(source, item)
        end
    end)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Get a formatted table of all shared vehicles
function GetSharedVehicles()
    if next(SharedVehicles) ~= nil then
        return SharedVehicles
    end

    local customSharedVehicles = GetCustomSharedVehicles()
    if customSharedVehicles then
        SharedVehicles = customSharedVehicles
        return SharedVehicles
    end

    for _, vehicle in pairs(QBCore.Shared.Vehicles) do
        if vehicle.hash ~= nil then
            if type(vehicle.hash) == 'string' then
                vehicle.hash = tonumber(vehicle.hash) or GetHashKey(vehicle.hash)
            end
            SharedVehicles[vehicle.hash] = {
                name = vehicle.name,
                model = vehicle.model,
                hash = vehicle.hash,
                price = vehicle.price,
                category = vehicle.category
            }
        end
    end
    return SharedVehicles
end

-- Get a formatted table of all shared jobs
function GetSharedJobs()
    if next(SharedJobs) ~= nil then
        return SharedJobs
    end

    for name, job in pairs(QBCore.Shared.Jobs) do
        SharedJobs[name] = {
            name = name,
            label = job.label,
            grades = {},
            boss_grade = nil,
        }

        for grade, v in pairs(job.grades) do
            local grade = tonumber(grade)
            SharedJobs[name].grades[grade] = {
                grade = grade,
                name = v.name
            }

            if v.isboss then
                SharedJobs[name].boss_grade = grade
            end
        end
    end
    return SharedJobs
end


-- Get a formatted table of all shared gangs
function GetSharedGangs()
    if next(SharedGangs) ~= nil then
        return SharedGangs
    end

    local customSharedGangs = GetCustomSharedGangs()
    if customSharedGangs then
        SharedGangs = customSharedGangs
        return SharedGangs
    end

    for name, gang in pairs(QBCore.Shared.Gangs) do
        SharedGangs[name] = {
            name = name,
            label = gang.label,
            grades = {},
            boss_grade = nil,
        }

        for grade, v in pairs(gang.grades) do
            local grade = tonumber(grade)
            SharedGangs[name].grades[grade] = {
                grade = grade,
                name = v.name
            }

            if v.isboss then
                SharedGangs[name].boss_grade = grade
            end
        end
    end

    return SharedGangs
end