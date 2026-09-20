--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

function GetPlayerData()
    if not CBUX.Ready then
        return nil
    end
    if CBUX.PlayerData then
        if Config.Cache.playerData then
            return CBUX.PlayerData
        end
    end
    if CBUX.Modules.Framework then
        if CBUX.Modules.Framework.GetPlayerData then
            local data = CBUX.Modules.Framework.GetPlayerData()
            if data then
                CBUX.PlayerData = data
            end
            return data
        end
    end
    return nil
end

function IsPlayerLoaded()
    if not CBUX.Ready then
        return false
    end
    if CBUX.Modules.Framework then
        if CBUX.Modules.Framework.IsPlayerLoaded then
            return CBUX.Modules.Framework.IsPlayerLoaded()
        end
    end
    return CBUX.PlayerData ~= nil
end

function GetJob()
    local data = GetPlayerData()
    if data then
        return data.job
    end
    return nil
end

function GetGang()
    local data = GetPlayerData()
    if data then
        return data.gang
    end
    return nil
end

function GetMoney(moneyType)
    local data = GetPlayerData()
    if data then
        if data.money then
            if moneyType then
                local amount = data.money[moneyType]
                if not amount then
                    amount = 0
                end
                return amount
            end
            return data.money
        end
    end
    if moneyType then
        return 0
    end
    return {}
end

function GetMetadata(key)
    local data = GetPlayerData()
    if data then
        if data.metadata then
            if key then
                return data.metadata[key]
            end
            return data.metadata
        end
    end
    return nil
end

function GetIdentifier()
    local data = GetPlayerData()
    if data then
        return data.identifier
    end
    return nil
end

function GetName()
    local data = GetPlayerData()
    if data then
        return data.name
    end
    return "Unknown"
end

function GetFirstName()
    local data = GetPlayerData()
    if data then
        if data.charinfo then
            return data.charinfo.firstname
        end
    end
    return "Unknown"
end

function GetLastName()
    local data = GetPlayerData()
    if data then
        if data.charinfo then
            return data.charinfo.lastname
        end
    end
    return "Player"
end

function GetCharInfo()
    local data = GetPlayerData()
    if data then
        return data.charinfo
    end
    return nil
end

function HasJob(jobName, grade)
    local job = GetJob()
    if not job then
        return false
    end
    if job.name ~= jobName then
        return false
    end
    if grade then
        if grade > job.grade then
            return false
        end
    end
    return true
end

function IsOnDuty()
    local job = GetJob()
    if job then
        return job.onDuty ~= false
    end
    return false
end

function IsBoss()
    local job = GetJob()
    if job then
        return job.isBoss == true
    end
    return false
end

function HasGang(gangName, grade)
    local gang = GetGang()
    if not gang then
        return false
    end
    if gang.name ~= gangName then
        return false
    end
    if grade then
        if grade > gang.grade then
            return false
        end
    end
    return true
end

function RefreshPlayerData()
    CBUX.PlayerData = nil
    return GetPlayerData()
end

function GetCoords()
    return GetEntityCoords(PlayerPedId())
end

function GetHeading()
    return GetEntityHeading(PlayerPedId())
end

function IsDead()
    local ped = PlayerPedId()
    local isDead = IsEntityDead(ped)
    if not isDead then
        isDead = IsPedDeadOrDying(ped, true)
    end
    return isDead
end

exports("GetPlayerData", GetPlayerData)
exports("IsPlayerLoaded", IsPlayerLoaded)
exports("GetJob", GetJob)
exports("GetGang", GetGang)
exports("GetMoney", GetMoney)
exports("GetMetadata", GetMetadata)
exports("GetIdentifier", GetIdentifier)
exports("GetName", GetName)
exports("GetFirstName", GetFirstName)
exports("GetLastName", GetLastName)
exports("GetCharInfo", GetCharInfo)
exports("HasJob", HasJob)
exports("IsOnDuty", IsOnDuty)
exports("IsBoss", IsBoss)
exports("HasGang", HasGang)
exports("RefreshPlayerData", RefreshPlayerData)
exports("GetCoords", GetCoords)
exports("GetHeading", GetHeading)
exports("IsDead", IsDead)