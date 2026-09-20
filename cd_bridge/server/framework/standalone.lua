if Cfg.Framework ~= 'standalone' then return end

local CharacterNames = {}
local SharedVehicles = {}
local SharedGangs = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

function HasFrameworkLoaded()
    return true
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           PLAYER DROP                            │
-- └──────────────────────────────────────────────────────────────────┘

if GetCurrentResourceName() == 'cd_bridge' then
    AddEventHandler('playerDropped', function(reason)
        local src = source
        reason = reason or 'dropped'
        TriggerEvent('cd_bridge:PlayerDropped', src, reason)
    end)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                              PLAYER                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the player object
function GetPlayer(source)
    return true
end

-- Get a specific identifier of a player
function GetIdentifier(source)
    return GetPlayerIdentifierByType(source, 'license')
end

-- Get the source from a unique identifier
function GetSourceFromIdentifier(identifier)
    local players = GetPlayers()
    for _, src in pairs(players) do
        src = tonumber(src)
        local id = GetIdentifier(src)
        if id == identifier then
            return src
        end
    end
end

-- Get a players character name
function GetCharacterName(source)
    if CharacterNames[source] then
        return CharacterNames[source]
    end

    local char_name = CapitalizeWords(GetPlayerName(source)) or Locale('unknown')
    CharacterNames[source] = char_name
    return char_name
end

function BanPlayer(source, reason)
    reason = reason or 'No reason specified'
    DropPlayer(source, reason)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               PERMS                              │
-- └──────────────────────────────────────────────────────────────────┘

local function getFivemIdentifiers(source)
    local result = {}
    for i = 0, GetNumPlayerIdentifiers(source) - 1 do
        local id = GetPlayerIdentifier(source, i)
        if not id then break end
        local colon = id:find(':', 1, true)
        table.insert(result, id:lower())
        table.insert(result, colon and id:sub(colon + 1):lower())
    end
    return result
end

local function getDiscordRoles(source)
    if GetResourceState('Badger_Discord_API') ~= 'started' then return {} end
    return exports.Badger_Discord_API:GetDiscordRoles(source)
end

-- Get the admin permissions/group of a player
function GetAdminPerms(source)
    if type(source) ~= 'number' or source <= 0 then return end

    local fivemIdentifiers = getDiscordRoles(source)
    local discordRoles = getFivemIdentifiers(source)

    local combined = {}
    for _, id in pairs(fivemIdentifiers) do
        table.insert(combined, id)
    end
    for _, id in pairs(discordRoles) do
        table.insert(combined, id)
    end
    return combined
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the job name of a player
function GetJobName(source)
    return 'unemployed'
end

-- Get the job label of a player
function GetJobLabel(source)
    return 'Unemployed'
end

-- Get the job grade of a player
function GetJobGrade(source)
    return 0
end

-- Get the job label of a player
function GetJobGradeLabel(source)
    return 'Unemployed'
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

    return true
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
    return 'none'
end

-- Get the gang label of the player
function GetGangLabel(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.label
    end
    return 'No Gang'
end

-- Get the gang grade of the player
function GetGangGrade(source)
    local customGang = GetCustomGang(source)
    if customGang ~= nil then
        return customGang.grade
    end
    return 0
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               MONEY                              │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the amount of money a player has
function GetPlayerMoney(source, money_type)
    local Player = GetPlayer(source)
    if not Player then return end

    return 1000000000
end

-- Add money to a player
function AddPlayerMoney(source, amount, money_type, reason)
    reason = reason or ''

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'deposit')
    end

    return true
end

-- Remove money from a player
function RemovePlayerMoney(source, amount, money_type, reason)
    reason = reason or ''

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'withdraw')
    end
    return true
end

-- Add money to an offline player
function AddMoneyToOfflinePlayer(identifier, amount, money_type, reason)

end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                               ITEMS                              │
-- └──────────────────────────────────────────────────────────────────┘

function RegisterUsableItem(item_name, onUse)
    return true
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Get all shared vehicles
function GetSharedVehicles()
    if next(SharedVehicles) ~= nil then
        return SharedVehicles
    end

    local customSharedVehicles = GetCustomSharedVehicles()
    if customSharedVehicles then
        SharedVehicles = customSharedVehicles
        return SharedVehicles
    end

    return SharedVehicles
end

function GetSharedJobs()
    return {}
end

function GetSharedGangs()
    if next(SharedGangs) ~= nil then
        return SharedGangs
    end

    local customSharedGangs = GetCustomSharedGangs()
    if customSharedGangs then
        SharedGangs = customSharedGangs
        return SharedGangs
    end
end