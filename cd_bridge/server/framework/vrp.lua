if Cfg.Framework ~= 'vrp' then return end

local CharacterNames = {}
local SharedVehicles = {}
local SharedGangs = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                            INITIALIZE                            │
-- └──────────────────────────────────────────────────────────────────┘

-- Initialize the framework object
local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRP = Proxy.getInterface("vRP")

function HasFrameworkLoaded()
    return vRP ~= nil
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
    local Player = vRP.getUserId({source})
    if not Player then return end
end

-- Get the unique identifier of a player
function GetIdentifier(source)
    local Player = GetPlayer(source)
    if not Player then return end

    return Player
end

-- Get the license identifier of a player
function GetLicenseIdentifier(source)
    return GetPlayerIdentifierByType(source, 'license')
end

-- Get the source from a unique identifier
function GetSourceFromIdentifier(identifier)
    local players = vRP.getUsers({})
    for _, src in pairs(players) do
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

-- Get the admin permissions/group of a player
function GetAdminPerms(source)
    local Player = GetPlayer(source)
    if not Player then return end

    return vRP.getUserAdminLevel({Player})
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                JOB                               │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the job name of a player
function GetJobName(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return vRP.getUserFaction(Player)
end

-- Get the job label of a player
function GetJobLabel(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return vRP.getUserFaction(Player)
end

-- Get the job grade of a player
function GetJobGrade(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return vRP.getFactionRank(Player)
end

-- Get the job label of a player
function GetJobGradeLabel(source)
    local Player = GetPlayer(source)
    if not Player then return false end

    return vRP.getUserFaction(Player)
end

-- Check if a player is on duty
function GetJobDuty(source)
    if Cfg.DisableDuty then
        return true
    end

    local customDuty = GetCustomJobDuty()
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

    if money_type == 'bank' then
        return vRP.getBankMoney({Player})

    elseif money_type == 'cash' then
        return vRP.getMoney({Player})
    end
end

-- Add money to a player
function AddPlayerMoney(source, amount, money_type, reason)
    local Player = GetPlayer(source)
    if not Player then return end

    if amount <= 0 then return end
    reason =  reason or ''

    local balance = GetPlayerMoney(source, money_type)
    if balance < amount then
        return false
    end

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'deposit')
    end

    vRP.tryPayment({Player, amount})
end

-- Remove money from a player
function RemovePlayerMoney(source, amount, money_type, reason)
    local Player = GetPlayer(source)
    if not Player then return end

    if amount <= 0 then return end
    reason =  reason or ''

    local balance = GetPlayerMoney(source, money_type)
    if balance < amount then
        return false
    end

    if Cfg.Banking ~= 'none'then
        LogTransaction(source, amount, money_type, reason, 'withdraw')
    end

    vRP.tryPayment({Player, amount})
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