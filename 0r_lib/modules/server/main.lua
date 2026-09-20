-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================


ResmonFramework = nil

Resmon.Lib.Players      = {}
Resmon.Lib.ServerCallbacks = {}
Resmon.Lib.Callback     = {}
Resmon.Lib.Craft        = {}
Resmon.Lib.Apartment    = {}
Resmon.Lib.Caravan      = {}
Resmon.Lib.PixelHouse   = {}
Resmon.Lib.IllegalPack  = {}

-- Detect ESX
if GetResourceState(Config.CoreName.ESX) ~= "missing" then
    Config.Framework = "ESX"
    ResmonFramework  = exports[Config.CoreName.ESX]:getSharedObject()
end

-- Detect QBCore
if GetResourceState(Config.CoreName.QBCore) ~= "missing" then
    Config.Framework = "QBCore"
    ResmonFramework  = exports[Config.CoreName.QBCore]:GetCoreObject()
end


-- ============================================================
--  UTILITY
-- ============================================================

--- Return the primary identifier (e.g. "steam:", "license:") for a player,
--- stripped of its prefix, by scanning GetPlayerIdentifiers.
function Resmon.Lib.PrimaryIdentifier(playerId)
    local prefix = Config.PrimaryIdentifier .. ":"
    for _, identifier in pairs(GetPlayerIdentifiers(playerId)) do
        if string.match(identifier, prefix) then
            return string.gsub(identifier, prefix, "")
        end
    end
end

--- Base64-decode a string. Returns the decoded binary string.
local function base64Decode(input)
    local b64chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

    -- Strip non-base64 characters (keep '=')
    input = string.gsub(input, "[^" .. b64chars .. "=]", "")

    -- Convert each character to 6-bit binary string
    local bitStr = string.gsub(input, ".", function(ch)
        if ch == "=" then return "" end
        local pos = b64chars:find(ch) - 1
        local bits = ""
        for i = 6, 1, -1 do
            local bit = pos % (2 ^ i) - pos % (2 ^ (i - 1))
            bits = bits .. (bit > 0 and "1" or "0")
        end
        return bits
    end)

    -- Convert each 8-bit group to a character
    return string.gsub(bitStr, "%d%d%d?%d?%d?%d?%d?%d?", function(byte)
        if #byte ~= 8 then return "" end
        local val = 0
        for i = 1, 8 do
            if byte:sub(i, i) == "1" then
                val = val + 2 ^ (8 - i)
            end
        end
        return string.char(val)
    end)
end

--- Decode a base64 data URI and save it as a file.
--- @param resourceName  string  Resource to resolve path for.
--- @param dataUri       string  Base64 data URI string.
--- @param fileName      string  Output filename inside the resource folder.
function Resmon.Lib.SaveImage(resourceName, dataUri, fileName)
    if type(dataUri) ~= "string" or dataUri == "" then return end
    local b64data = dataUri:match("base64,(.*)")
    if not b64data then return end
    local decoded  = base64Decode(b64data)
    local resPath  = GetResourcePath(resourceName)
    if not resPath or resPath == "" then return end
    local filePath = resPath .. "/" .. fileName
    local file     = io.open(filePath, "wb")
    if not file then return end
    file:write(decoded)
    file:close()
end

--- Execute a parameterised UPDATE on the 0r_motels table.
--- @param column  string  Column to update.
--- @param value   any     New value.
--- @param mcode   string  Motel code to match.
function Resmon.Lib.UpdateMotelSQL(column, value, mcode)
    MySQL.update.await("UPDATE 0r_motels SET " .. column .. " = ? WHERE mcode = ?", { value, mcode })
end

--- Insert a crafting queue entry for a player.
--- Returns the new row's insert ID.
function Resmon.Lib.Craft.InsertQueueToDB(player, item)
    local identifier
    if Config.Framework == "ESX" and player.identifier then
        identifier = player.identifier
    else
        identifier = player.PlayerData.citizenid
    end

    return MySQL.insert.await(
        "INSERT INTO `0r_crafting_queue` (user, name, label, count, duration, image, ingredients, propModel, price, canItBeCraftable) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
        {
            identifier,
            item.name        or "Unknown",
            item.label       or "Unknown",
            item.count       or 1,
            item.duration    or 1000,
            item.image       or "Unknown",
            json.encode(item.ingredients or {}),
            item.propModel   or "",
            item.price       or 0,
            item.canItBeCraftable or 0,
        }
    )
end

--- Return "Firstname Lastname" for an offline player by identifier.
function Resmon.Lib.GetPlayerOfflineName(identifier)
    local name = "No Owner"

    if Config.Framework == "ESX" then
        local rows = MySQL.query.await("SELECT * FROM users WHERE identifier = @id", { ["@id"] = identifier })
        if #rows > 0 then
            name = rows[1].firstname .. " " .. rows[1].lastname
        end
    else
        local rows = MySQL.query.await("SELECT * FROM players WHERE citizenid = @id", { ["@id"] = identifier })
        if #rows > 0 then
            local charinfo = json.decode(rows[1].charinfo)
            name = charinfo.firstname .. " " .. charinfo.lastname
        end
    end

    return name
end

--- Return (jobName, gradeLevel) for a player by CID/identifier.
--- Checks online players first, then falls back to the database.
function Resmon.Lib.GetPlayerFromCid(identifier)
    local player = Resmon.Lib.GetPlayerByIdentifier(identifier)

    if player == nil then
        if Config.Framework == "ESX" then
            local rows = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = ?", { identifier })
            if #rows > 0 then
                return rows[1].job, rows[1].job_grade
            end
        else
            local rows = MySQL.Sync.fetchAll("SELECT * FROM players WHERE citizenid = ?", { identifier })
            if #rows > 0 then
                local row = rows[1]
                row.job = json.decode(row.job)
                return row.job.name, row.job.grade.level
            end
        end
    else
        local onlinePlayer = Resmon.Lib.GetPlayerFromSource(player)
        if onlinePlayer then
            return onlinePlayer.job.name, onlinePlayer.job.gradelevel
        end
    end
end

--- Return the source (player ID) for a player by their identifier/citizenid.
function Resmon.Lib.GetIdentifier(playerId)
    if Config.Framework == "ESX" then
        local xPlayer = ResmonFramework.GetPlayerFromId(playerId)
        return xPlayer and xPlayer.identifier or nil
    elseif Config.Framework == "QBCore" then
        local player = ResmonFramework.Functions.GetPlayer(playerId)
        if player and player.PlayerData then
            return player.PlayerData.citizenid
        end
        return nil
    else
        return Resmon.Lib.PrimaryIdentifier(playerId)
    end
end

--- Return the "license:" identifier string for a player.
function Resmon.Lib.GetPlayerLicense(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, identifier in ipairs(identifiers) do
        if string.find(identifier, "license:") then
            return identifier
        end
    end
    return nil
end

--- Return a list of all tracked player IDs.
function Resmon.Lib.GetPlayers()
    local result = {}
    for playerId, _ in pairs(Resmon.Lib.Players) do
        result[#result + 1] = playerId
    end
    return result
end

--- Return all active players via the framework.
function Resmon.Lib.AllPlayers()
    if Config.Framework == "ESX" then
        return ResmonFramework.GetPlayers()
    else
        return ResmonFramework.Functions.GetPlayers()
    end
end

--- Return a list of all job employees (both online and offline) for a given job list.
function Resmon.Lib.GetJobEmployeeCount(jobName)
    local result = {}

    if Config.Framework == "QBCore" then
        local rows = MySQL.query.await("SELECT * FROM players")
        for _, row in pairs(rows) do
            if row.job ~= nil then
                row.job = json.decode(row.job)
                if row.job.name == jobName then
                    table.insert(result, {
                        name       = Resmon.Lib.GetPlayerOfflineName(row.citizenid),
                        job        = row.job.name,
                        grade      = row.job.grade.name,
                        identifier = row.citizenid,
                    })
                end
            end
        end
    else
        local rows = MySQL.query.await("SELECT * FROM users WHERE job = @job", { ["@job"] = jobName })
        for _, row in pairs(rows) do
            table.insert(result, {
                name       = Resmon.Lib.GetPlayerOfflineName(row.identifier),
                job        = row.job,
                grade      = row.job_grade,
                identifier = row.identifier,
            })
        end
    end

    return result
end

--- Return (source, distance) for the online player whose identifier matches.
function Resmon.Lib.GetPlayerByIdentifier(identifier)
    if Config.Framework == "ESX" then
        local xPlayer = ResmonFramework.GetPlayerFromIdentifier(identifier)
        return xPlayer and xPlayer.source or nil
    else
        local player = ResmonFramework.Functions.GetPlayerByCitizenId(identifier)
        if player and player.PlayerData then
            return player.PlayerData.source
        end
        return nil
    end
end

--- Return the framework name string.
function Resmon.Lib.GetFramework()
    return Config.Framework
end

exports("GetFramework", function()
    return Config.Framework
end)

--- Return the framework player object for a given source ID.
function Resmon.Lib.GetPlayerBySource(playerId)
    local id = tonumber(playerId)
    if Config.Framework == "ESX" then
        return ResmonFramework.GetPlayerFromId(id)
    elseif Config.Framework == "QBCore" then
        return ResmonFramework.Functions.GetPlayer(id)
    end
end

--- Iterate all QBX players and call cb(player) for each admin/opt-in player.
if GetResourceState("qbx_core") ~= "missing" then
    function OnAdmin(ace, cb)
        for playerId, player in pairs(exports.qbx_core:GetQBPlayers()) do
            if IsPlayerAceAllowed(playerId, ace) and exports.qbx_core:IsOptin(playerId) then
                cb(player)
            end
        end
    end
end

--- Return true if the player has admin rights or the required permission group.
--- @param playerId   number         Server player ID.
--- @param groups     string|table   Group name or list of group names.
function Resmon.Lib.CheckPlayerPermission(playerId, groups)
    if IsPlayerAceAllowed(playerId, "admin") then
        return true
    end

    if GetResourceState(Config.CoreName.QBCore) == "started" then
        local QB     = exports[Config.CoreName.QBCore]:GetCoreObject()
        local player = QB.Functions.GetPlayer(playerId)
        if player then
            local group = player.PlayerData.permission or player.PlayerData.group
            if group then
                if type(groups) == "table" then
                    for _, g in pairs(groups) do
                        if group == g then return true end
                    end
                elseif group == groups then
                    return true
                end
            end
        end
    end

    if GetResourceState(Config.CoreName.ESX) == "started" then
        local ESX    = exports[Config.CoreName.ESX]:getSharedObject()
        local player = ESX.GetPlayerFromId(playerId)
        if player then
            local group = player.getGroup()
            if group then
                if type(groups) == "table" then
                    for _, g in pairs(groups) do
                        if group == g then return true end
                    end
                elseif group == groups then
                    return true
                end
            end
        end
    end

    return false
end

--- Fetch offline player data from the database.
--- @param source      number   Pass -1 to skip online check.
--- @param identifier  string   Player identifier/citizenid.
function Resmon.Lib.GetPlayerOfflineData(source, identifier)
    if source > 0 then
        local player = Resmon.Lib.GetPlayerFromSource(source)
        if player then return player end
    end

    local dbMap = {
        ESX    = { users = "users",   identifier = "identifier" },
        QBCore = { users = "players", identifier = "citizenid"  },
    }
    local map  = dbMap[Config.Framework]
    local rows = MySQL.Sync.fetchAll(
        "SELECT * FROM " .. map.users .. " WHERE " .. map.identifier .. " = ?",
        { identifier }
    )

    if rows[1] then
        local data = rows[1]
        if Config.Framework == "ESX" then
            data.birthdate = data.dateofbirth
            data.gender    = data.sex
            data.name      = data.firstname .. " " .. data.lastname
        else
            local charinfo = json.decode(data.charinfo)
            charinfo.name       = charinfo.firstname .. " " .. charinfo.lastname
            charinfo.identifier = rows[1].citizenid
            charinfo.license    = rows[1].license
            return charinfo
        end
        return data
    end

    return nil
end

--- Add `days` days to today's date and return the resulting date as "YYYY-MM-DD".
function Resmon.Lib.AddDaysToDate(days)
    local today  = os.date("%Y-%m-%d")
    local y, m, d = today:match("(%d+)%-(%d+)%-(%d+)")
    local ts     = os.time({ year = tonumber(y), month = tonumber(m), day = tonumber(d) })
    ts = ts + days * 24 * 60 * 60
    return os.date("%Y-%m-%d", ts)
end

--- Return all jobs as { jobLabel, jobName } from the framework or the database.
function Resmon.Lib.GetServerJobs()
    local result = {}
    if Config.Framework == "QBCore" then
        for jobName, jobData in pairs(ResmonFramework.Shared.Jobs) do
            result[#result + 1] = { jobLabel = jobData.label, jobName = jobName }
        end
    else
        local rows = MySQL.Sync.fetchAll("SELECT * FROM jobs")
        for _, row in pairs(rows) do
            result[#result + 1] = { jobLabel = row.label, jobName = row.name }
        end
    end
    return result
end

--- Return a map of { [jobName] = { {gradelevel, label}, ... } } for the given job(s).
--- @param jobs  string|table  Single job name or a list.
function Resmon.Lib.GetJobGrades(jobs)
    local result = {}
    if type(jobs) ~= "table" then jobs = { jobs } end

    if Config.Framework == "ESX" then
        local placeholders = {}
        for _ = 1, #jobs do table.insert(placeholders, "?") end
        local query = "SELECT * FROM job_grades WHERE job_name IN (" .. table.concat(placeholders, ",") .. ")"
        local rows  = MySQL.Sync.fetchAll(query, jobs)
        for _, row in ipairs(rows) do
            if not result[row.job_name] then result[row.job_name] = {} end
            table.insert(result[row.job_name], { gradelevel = row.grade, label = row.label })
        end
    else
        for _, jobName in ipairs(jobs) do
            local jobDef = ResmonFramework.Shared.Jobs[jobName]
            if jobDef and jobDef.grades then
                result[jobName] = {}
                for gradeLevel, gradeData in pairs(jobDef.grades) do
                    table.insert(result[jobName], { gradelevel = gradeLevel, label = gradeData.name })
                end
            end
        end
    end

    return result
end

--- Generate a random 10-character hex string.
function Resmon.Lib.GenerateHash()
    local chars  = "0123456789abcdef"
    local result = ""
    for _ = 1, 10 do
        local idx = math.random(#chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

--- Return the job label for a given job name, or nil if not found.
function Resmon.Lib.GetJobLabelFromName(jobName)
    local label = "Unkown"

    if Config.Framework == "ESX" then
        -- NOTE: original SQL has a typo "job name" (space) — preserved as-is
        local rows = MySQL.Sync.fetchAll("SELECT * FROM jobs WHERE job name = ?", { jobName })
        if #rows > 0 then label = rows[1].label end
    else
        local jobDef = ResmonFramework.Shared.Jobs[jobName]
        label = jobDef and jobDef.label or label
    end

    if label == "Unkown" then return nil end
    return label
end

--- Return the grade label for a job/grade combination.
function Resmon.Lib.GetJobGradeLabel(jobName, gradeLevel)
    local grades = Resmon.Lib.GetJobGrades(jobName)
    for _, grade in pairs(grades) do
        if grade.gradelevel == gradeLevel then
            return grade.label
        end
    end
    return "Unkown"
end

--- Return the ESX job label from the jobs table by job name.
function Resmon.Lib.GetEsxJobLabelFromName(jobName)
    local rows = MySQL.Sync.fetchAll("SELECT * FROM jobs WHERE name = ?", { jobName })
    if #rows > 0 then return rows[1].label end
end

--- Return a list of all players (online + offline) matching the given job list,
--- with normalised fields: cid, name, joborg, jobname, gradelevel, gradename, online.
function Resmon.Lib.GetUsersFromJobs(jobs)
    local result   = {}
    local seenCids = {}

    if Config.Framework == "ESX" then
        -- Online players
        for _, playerId in ipairs(Resmon.Lib.AllPlayers()) do
            local player = Resmon.Lib.GetPlayerFromSource(playerId)
            for _, jobName in ipairs(jobs) do
                if player.job.name == jobName then
                    local cid = player.identifier
                    table.insert(result, {
                        cid        = cid,
                        name       = player.name,
                        joborg     = player.job.name,
                        jobname    = Resmon.Lib.GetEsxJobLabelFromName(player.job.name),
                        gradelevel = player.job.gradelevel,
                        gradename  = Resmon.Lib.GetJobGradeLabel(player.job.name),
                        online     = true,
                    })
                    seenCids[cid] = true
                    break
                end
            end
        end

        -- Offline players
        local placeholders = {}
        for _ = 1, #jobs do table.insert(placeholders, "?") end
        local query = "SELECT * FROM users WHERE job IN (" .. table.concat(placeholders, ",") .. ")"
        local rows  = MySQL.Sync.fetchAll(query, jobs)
        for _, row in pairs(rows) do
            local src = Resmon.Lib.GetPlayerByIdentifier(row.identifier)
            local p   = src and Resmon.Lib.GetPlayerFromSource(src) or nil
            local entry = {
                cid        = row.identifier,
                name       = row.firstname .. " " .. row.lastname,
                jobname    = Resmon.Lib.GetEsxJobLabelFromName(row.job),
                gradelevel = p and p.job.gradelevel or row.job_grade,
                gradename  = Resmon.Lib.GetJobGradeLabel(row.job),
            }
            result[#result + 1] = entry
        end
    else
        -- QBCore: online first
        for _, playerId in ipairs(Resmon.Lib.AllPlayers()) do
            local player = Resmon.Lib.GetPlayerFromSource(playerId)
            for _, jobName in ipairs(jobs) do
                if player.job.name == jobName then
                    local cid = player.identifier
                    table.insert(result, {
                        cid        = cid,
                        name       = player.name,
                        joborg     = player.job.name,
                        jobname    = player.job.name,
                        gradelevel = player.job.gradelevel,
                        gradename  = player.job.grade.name,
                        online     = true,
                    })
                    seenCids[cid] = true
                    break
                end
            end
        end

        -- Offline
        local placeholders = {}
        for _ = 1, #jobs do table.insert(placeholders, "?") end
        local query = 'SELECT * FROM players WHERE JSON_UNQUOTE(JSON_EXTRACT(job, "$.name")) IN (' .. table.concat(placeholders, ",") .. ")"
        local rows  = MySQL.Sync.fetchAll(query, jobs)
        for _, row in ipairs(rows) do
            row.charinfo = json.decode(row.charinfo)
            row.job      = json.decode(row.job)
            if not seenCids[row.citizenid] then
                table.insert(result, {
                    cid        = row.citizenid,
                    name       = row.charinfo.firstname .. " " .. row.charinfo.lastname,
                    joborg     = row.job.name,
                    jobname    = row.job.label,
                    gradelevel = row.job.grade.level,
                    gradename  = row.job.grade.name,
                    online     = false,
                })
            end
        end
    end

    return result
end

--- Build and return a normalised player wrapper for a connected source.
--- Adds unified helpers: GetAccountData, AddItem, RemoveItem, GiveAccountMoney, RemoveMoney.
function Resmon.Lib.GetPlayerFromSource(playerId)
    if not playerId then return end

    local player

    if Config.Framework == "ESX" then
        player = ResmonFramework.GetPlayerFromId(playerId)
        if not player then
            while not player do Wait(100) end
        end
        local offlineData = Resmon.Lib.GetPlayerOfflineData(-1, player.identifier)
        player.name      = player:getName()
        player.cash      = player:getAccount("money").money
        player.bank      = player:getAccount("bank").money
        player.coords    = player:getCoords(true)
        player.job.gradelevel = player.job.grade
        player.birthdate = offlineData and offlineData.birthdate or nil

    elseif Config.Framework == "QBCore" then
        player = ResmonFramework.Functions.GetPlayer(playerId)
        if not player then return end

        player.name       = player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
        player.license    = player.PlayerData.license
        player.identifier = player.PlayerData.citizenid
        player.job        = player.PlayerData.job
        player.job.name   = player.PlayerData.job.name
        player.job.gradelevel  = player.PlayerData.job.grade.level
        player.job.grade_name  = player.PlayerData.job.grade.name
        player.cash       = player.PlayerData.money.cash
        player.bank       = player.PlayerData.money.bank
        player.source     = player.PlayerData.source
        player.birthdate  = player.PlayerData.charinfo.birthdate
        player.coords     = ResmonFramework.Functions.GetCoords(GetPlayerPed(playerId))
    end

    return Resmon.Lib.RemapPlayer(player)
end

--- Attach unified helper methods to any framework player object.
function Resmon.Lib.RemapPlayer(player)
    local helpers = {}

    function helpers.GetAccountData(accountName)
        if Config.Framework == "ESX" then
            if accountName == "cash" then accountName = "money" end
            return player:getAccount(accountName).money
        else
            return player.PlayerData.money[accountName]
        end
    end

    function helpers.AddItem(itemName, count, slot, metadata)
        if Config.Framework == "ESX" then
            return player.addInventoryItem(itemName, count, slot, metadata)
        else
            return player.Functions.AddItem(itemName, count, slot, metadata)
        end
    end

    function helpers.RemoveItem(itemName, count, slot, metadata)
        if Config.Framework == "ESX" then
            return player.removeInventoryItem(itemName, count, slot, metadata)
        else
            return player.Functions.RemoveItem(itemName, count, slot, metadata)
        end
    end

    function helpers.GiveAccountMoney(accountName, amount)
        if Config.Framework == "ESX" then
            if accountName == "cash" then accountName = "money" end
            player.addAccountMoney(accountName, amount)
        else
            player.Functions.AddMoney(accountName, amount)
        end
    end

    function helpers.RemoveMoney(accountName, amount)
        if Config.Framework == "ESX" then
            if accountName == "cash" then accountName = "money" end
            return player.removeAccountMoney(accountName, amount)
        else
            return player.Functions.RemoveMoney(accountName, amount)
        end
    end

    return Resmon.Lib.MergeTable(helpers, player)
end

--- Remove money from an online or offline player by identifier.
--- Returns true on success, false if insufficient funds.
function Resmon.Lib.RemoveMoneyOfflineOrOnline(identifier, amount)
    local source = Resmon.Lib.GetPlayerByIdentifier(identifier)
    local success = false

    if source and source > 0 then
        local player = Resmon.Lib.GetPlayerFromSource(source)
        if player and amount <= player.bank then
            player.RemoveMoney("bank", amount)
            success = true
        end
    else
        if Config.Framework == "QBCore" then
            local rows = MySQL.Sync.fetchAll("SELECT money FROM players WHERE citizenid = ?", { identifier })
            if rows[1] then
                local money = json.decode(rows[1].money)
                if amount <= money.bank then
                    money.bank = money.bank - amount
                    MySQL.Async.execute(
                        "UPDATE players SET money = ? WHERE citizenid = ?",
                        { json.encode(money), identifier }
                    )
                    success = true
                end
            end
        else
            local rows = MySQL.Sync.fetchAll("SELECT accounts FROM users WHERE identifier = ?", { identifier })
            if rows[1] then
                local accounts = json.decode(rows[1].accounts)
                if amount <= accounts.bank then
                    accounts.bank = accounts.bank - amount
                    MySQL.Async.execute(
                        "UPDATE users SET accounts = ? WHERE citizenid = ?",
                        { json.encode(accounts), identifier }
                    )
                    success = true
                end
            end
        end
    end

    return success
end

--- Set a player's job (online or offline by identifier).
function Resmon.Lib.SetPlayerJob(identifier, jobName, gradeLevel)
    print(identifier, jobName, gradeLevel)
    local source = Resmon.Lib.GetPlayerByIdentifier(identifier)

    if Config.Framework == "ESX" then
        if source then
            local xPlayer = ResmonFramework.GetPlayerFromId(source)
            xPlayer.setJob(jobName, gradeLevel)
        else
            local rows = MySQL.query.await("SELECT * FROM users WHERE identifier = ?", { identifier })
            if rows[1] then
                MySQL.update(
                    "UPDATE users SET job = ?, job_grade = ? WHERE identifier = ?",
                    { jobName, gradeLevel, identifier }
                )
            end
        end
    elseif source then
        local player = ResmonFramework.Functions.GetPlayer(source)
        player.Functions.SetJob(jobName, gradeLevel)
    else
        local rows = MySQL.query.await("SELECT * FROM players WHERE citizenid = ?", { identifier })
        if rows[1] then
            local gradeStr = tostring(gradeLevel)
            local jobDef   = ResmonFramework.Shared.Jobs[jobName]
            local jobTable = {
                name    = jobName,
                label   = jobDef.label,
                type    = jobDef.type,
                payment = jobDef.payment,
                isboss  = jobDef.grades[gradeStr].isboss,
                onduty  = true,
                grade   = {
                    name    = jobDef.grades[gradeStr].name,
                    level   = gradeLevel,
                    payment = jobDef.grades[gradeStr].payment,
                    isboss  = jobDef.grades[gradeStr].isboss,
                },
            }
            MySQL.update(
                "UPDATE players SET job = ? WHERE citizenid = ?",
                { json.encode(jobTable), identifier }
            )
        end
    end
end

--- Return the character's display name for a connected player.
function Resmon.Lib.GetPlayerCharacterName(playerId)
    if Config.Framework == "ESX" then
        return ResmonFramework.GetPlayerFromId(playerId).name
    elseif Config.Framework == "QBCore" then
        local player = ResmonFramework.Functions.GetPlayer(playerId)
        return player.PlayerData.charinfo.firstname .. " " .. player.PlayerData.charinfo.lastname
    end
end

--- Return the account balance for a player by source.
--- @param playerId    number  Server source ID.
--- @param accountName string  "cash", "bank", etc.
function Resmon.Lib.GetPlayerBalance(playerId, accountName)
    if Config.Framework == "ESX" then
        local xPlayer = ResmonFramework.GetPlayerFromId(playerId)
        if accountName == "cash" then accountName = "money" end
        return xPlayer:getAccount(accountName).money
    elseif Config.Framework == "QBCore" then
        local player = ResmonFramework.Functions.GetPlayer(playerId)
        return player.PlayerData.money[accountName]
    end
end

--- Deep-merge table `src` into table `dest`. Returns `dest`.
function Resmon.Lib.MergeTable(dest, src)
    if not src then return dest end
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then dest[k] = {} end
            Resmon.Lib.MergeTable(dest[k], src[k])
        else
            dest[k] = v
        end
    end
    return dest
end

--- Serialize a value to a pretty-printed string (same as client-side DumpTable).
function Resmon.Lib.DumpTable(value, depth)
    depth = depth or 0
    if type(value) == "table" then
        local indent = string.rep("    ", depth + 1)
        local result = "{\n"
        for k, v in pairs(value) do
            if type(k) ~= "number" then k = '"' .. k .. '"' end
            result = result .. string.rep("    ", depth) .. "[" .. k .. "] = " .. Resmon.Lib.DumpTable(v, depth + 1) .. ",\n"
        end
        return result .. string.rep("    ", depth) .. "}"
    else
        return tostring(value)
    end
end

--- Round a number to `decimals` places (defaults to integer rounding).
function Resmon.Lib.Round(value, decimals)
    local fmt    = "%." .. (decimals or 0) .. "f"
    return tonumber(string.format(fmt, value))
end

--- Format a number with locale digit grouping separators.
function Resmon.Lib.GroupDigits(n)
    local head, mid, tail = string.match(tostring(n), "^([^%d]*%d)(%d*)(.-)$")
    local sep  = _U("locale_digit_grouping_symbol")
    local grouped = mid:reverse():gsub("(%d%d%d)", "%1" .. sep):reverse()
    return head .. grouped .. tail
end

--- Trim leading and trailing whitespace from a string.
function Resmon.Lib.Trim(str)
    if str then
        return string.gsub(str, "^%s*(.-)%s*$", "%1")
    end
    return nil
end

--- Parse a "YYYY-MM-DD" date string into { year, month, day }.
function Resmon.Lib.ParseDate(dateStr)
    local y, m, d = dateStr:match("(%d+)-(%d+)-(%d+)")
    return { year = tonumber(y), month = tonumber(m), day = tonumber(d) }
end

--- Return the number of whole days between two "YYYY-MM-DD" date strings.
function Resmon.Lib.DaysBetweenDates(dateA, dateB)
    local y1, m1, d1 = dateA:match("(%d+)-(%d+)-(%d+)")
    local y2, m2, d2 = dateB:match("(%d+)-(%d+)-(%d+)")
    local t1 = os.time({ year = y1, month = m1, day = d1 })
    local t2 = os.time({ year = y2, month = m2, day = d2 })
    return math.floor((t2 - t1) / 86400)
end

--- Generate a random 6-character alphanumeric string.
function Resmon.Lib.A11566D()
    local chars  = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    for _ = 1, 6 do
        local idx = math.random(1, #chars)
        result = result .. chars:sub(idx, idx)
    end
    return result
end

--- Register a usable item with the framework.
function Resmon.Lib.RegisterUsableItem(itemName, cb)
    if Config.Framework == "QBCore" then
        ResmonFramework.Functions.CreateUseableItem(itemName, cb)
    else
        ResmonFramework.RegisterUsableItem(itemName, cb)
    end
end

--- Return the vehicle table name and identifier column based on the framework config.
function Resmon.Lib.GetVehiclesTableName()
    if Config.Framework == "ESX" then
        return Config.VehicleUpdateSQLESX
    else
        return Config.VehicleUpdateSQLQBCore
    end
end

--- Safe JSON decode: returns {} on error or non-table result.
local function safeJsonDecode(str)
    if type(str) ~= "string" or str == "" then return {} end
    local ok, result = pcall(json.decode, str)
    if ok and type(result) == "table" then return result end
    return {}
end


-- ============================================================
--  CALLBACKS
-- ============================================================

--- Register a named server callback handler.
function Resmon.Lib.Callback.Register(name, handler)
    Resmon.Lib.ServerCallbacks[name] = handler
end

--- Invoke a named server callback from the client side.
--- @param name       string  Callback name.
--- @param requestId  number  Client-side request ID for the response.
--- @param playerId   number  Source player.
--- @param cb         function Response function — sends result back to client.
function Resmon.Lib.Callback.Client(name, requestId, playerId, cb, ...)
    local handler = Resmon.Lib.ServerCallbacks[name]
    if handler then
        handler(playerId, cb, ...)
    else
        print(('[^3WARNING^7] Server callback ^5"%s"^0 does not exist. ^1Please Check The Server File for Errors!'):format(name))
    end
end

RegisterServerEvent("0R:Core:TriggerCallback")
AddEventHandler("0R:Core:TriggerCallback", function(name, requestId, ...)
    local playerId = source
    Resmon.Lib.Callback.Client(name, requestId, playerId, function(...)
        TriggerClientEvent("0R:Core:ServerCallback", playerId, requestId, ...)
    end, ...)
end)

--- Day-calculator callback: returns the number of days until (or since) a date.
Resmon.Lib.Callback.Register("0R:Core:Server:CalculatorDay", function(playerId, cb, _, dateStr)
    local nowTs    = os.time()
    local parsed   = Resmon.Lib.ParseDate(dateStr)
    local targetTs = os.time(parsed)
    local days     = Resmon.Lib.Round(math.abs(targetTs - nowTs) / 86400)
    cb(days)
end)

--- Vehicle ownership callback.
Resmon.Lib.Callback.Register("0R:Lib:CheckVehicleOwner", function(playerId, cb, _, plate)
    local player    = Resmon.Lib.GetPlayerFromSource(playerId)
    local tableName = Resmon.Lib.GetVehiclesTableName()
    local rows      = MySQL.query.await(
        "SELECT * FROM " .. tableName[1] .. " WHERE plate = ?",
        { plate }
    )
    if #rows >= 1 then
        local ownerField = tableName[2]
        cb(rows[1][ownerField] == player.identifier)
    else
        cb(false)
    end
end)


-- ============================================================
--  NOTIFY EXPORT
-- ============================================================

exports("Notify", function(playerId, data)
    TriggerClientEvent("0R:Lib:Notify", playerId, data)
end)


-- ============================================================
--  PLAYER DATA
-- ============================================================

--- Return a full MySQL players list with parsed JSON fields and normalised names.
function Resmon.Lib.GetMysqlPlayers()
    local result = {}

    if Config.Framework == "QBCore" then
        local rows = MySQL.Sync.fetchAll("SELECT * FROM players") or {}
        for _, row in pairs(rows) do
            if type(row) == "table" and row.citizenid then
                row.charinfo  = safeJsonDecode(row.charinfo)
                row.job       = safeJsonDecode(row.job)
                row.money     = safeJsonDecode(row.money)
                row.metadata  = safeJsonDecode(row.metadata)

                local licenses = row.metadata.licences or row.metadata.licenses or {}
                if type(licenses) ~= "table" then licenses = {} end

                local firstname = row.charinfo.firstname or ""
                local lastname  = row.charinfo.lastname  or ""
                local name      = (firstname .. " " .. lastname):gsub("^%s+", ""):gsub("%s+$", "")

                local jobLabel = ""
                if type(row.job) == "table" then
                    jobLabel = row.job.label or row.job.name or ""
                end

                local bank = (type(row.money.bank) == "number" and row.money.bank) or 0

                result[#result + 1] = {
                    pName       = name,
                    cid         = row.citizenid,
                    birthdate   = row.charinfo.birthdate   or "",
                    job         = jobLabel,
                    phone       = row.charinfo.phone       or "",
                    nationality = row.charinfo.nationality or "",
                    gender      = row.charinfo.gender      or "",
                    bank        = bank,
                    dlicense    = licenses.driver == true,
                }
            end
        end
    else
        local rows = MySQL.Sync.fetchAll("SELECT * FROM users") or {}
        for _, row in pairs(rows) do
            if type(row) == "table" and row.identifier then
                row.accounts = safeJsonDecode(row.accounts)
                local firstname = row.firstname or ""
                local lastname  = row.lastname  or ""
                local name      = (firstname .. " " .. lastname):gsub("^%s+", ""):gsub("%s+$", "")
                local bank      = (type(row.accounts.bank) == "number" and row.accounts.bank) or 0
                result[#result + 1] = {
                    pName  = name,
                    cid    = row.identifier,
                    job    = row.job    or "",
                    gender = row.sex    or "",
                    bank   = bank,
                }
            end
        end
    end

    return result
end

--- Spawn callback (named "CemKaraca"): spawns a vehicle for a player and returns its net ID.
Resmon.Lib.Callback.Register("CemKaraca", function(playerId, cb, model, coords, heading)
    local vehicle = Resmon.Lib.SpawnVehicle(playerId, model, coords, heading)
    cb(NetworkGetNetworkIdFromEntity(vehicle))
end)

--- Spawn a networked vehicle for `playerId` and wait until the player is its network owner.
--- @param playerId  number   Server source.
--- @param model     string|number  Model name or hash.
--- @param coords    vector3  Spawn position (with optional .w for heading).
--- @param warpIn    boolean  Warp the player ped into the vehicle.
function Resmon.Lib.SpawnVehicle(playerId, model, coords, warpIn)
    local ped = GetPlayerPed(playerId)
    if type(model) == "string" then model = joaat(model) end
    if not coords then coords = GetEntityCoords(ped) end
    local heading = coords.w or 0.0

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, true)
    while not DoesEntityExist(vehicle) do Wait(0) end

    if warpIn then
        while GetVehiclePedIsIn(ped) ~= vehicle do
            Wait(0)
            TaskWarpPedIntoVehicle(ped, vehicle, -1)
        end
    end

    while NetworkGetEntityOwner(vehicle) ~= playerId do Wait(0) end

    return vehicle
end


-- ============================================================
--  APARTMENT
-- ============================================================

--- Delete expired apartment rooms from the database.
function Resmon.Lib.Apartment.DestroyRooms()
    return MySQL.query.await("DELETE FROM `0resmon_apartment_rooms` WHERE due_date < NOW() AND life_time = 0")
end

--- Return all sold apartment rooms with parsed JSON fields.
function Resmon.Lib.Apartment.GetSoldRooms()
    Resmon.Lib.Apartment.DestroyRooms()
    local rows = MySQL.query.await("SELECT * FROM `0resmon_apartment_rooms`")
    for _, room in pairs(rows) do
        room.options     = json.decode(room.options     or "{}")
        room.permissions = json.decode(room.permissions or "{}")
        room.indicators  = json.decode(room.indicators  or "{}")
        room.furnitures  = json.decode(room.furnitures  or "{}")
        for idx, furniture in pairs(room.furnitures) do
            if furniture.isPlaced then furniture.index = idx end
        end
        room.players = {}
    end
    return rows
end

--- Insert a new apartment room sale and return the new room object.
function Resmon.Lib.Apartment.OnNewRoomSold(apartmentId, roomId, owner, ownerName, days, lifetime)
    local dueTs = (os.time() + days * 24 * 60 * 60) * 1000
    MySQL.insert.await(
        "INSERT INTO `0resmon_apartment_rooms` (apartment_id, room_id, owner, owner_name, due_date, life_time) VALUES (?, ?, ?, ?, DATE_ADD(NOW(), INTERVAL ? DAY), ?)",
        { apartmentId, roomId, owner, ownerName, days, days == 0 }
    )
    return {
        apartment_id = apartmentId,
        room_id      = roomId,
        owner        = owner,
        owner_name   = ownerName,
        life_time    = lifetime,
        due_date     = dueTs,
        options      = {},
        permissions  = {},
        furnitures   = {},
        indicators   = {},
        players      = {},
    }
end


-- ============================================================
--  CARAVAN
-- ============================================================

--- Return all licensed caravans with parsed JSON fields.
function Resmon.Lib.Caravan.GetLicensedPlates()
    local rows = MySQL.query.await("SELECT * FROM `0resmon_caravans`")
    for _, caravan in pairs(rows) do
        caravan.sql_id      = caravan.id
        caravan.options     = json.decode(caravan.options)
        caravan.permissions = json.decode(caravan.permissions)
        caravan.meta        = json.decode(caravan.meta)
        caravan.furnitures  = json.decode(caravan.furnitures)
        for idx, furniture in pairs(caravan.furnitures) do
            if furniture.isPlaced then furniture.index = idx end
        end
        caravan.players = {}
    end
    return rows
end

--- Save a new caravan license to the database and return the caravan object.
function Resmon.Lib.Caravan.SaveLicense(playerId, owner, plate)
    local ownerName  = Resmon.Lib.GetPlayerCharacterName(playerId)
    local today      = os.date("%Y-%m-%d")
    local options    = { design = "empty" }
    local insertId   = MySQL.insert.await(
        "INSERT IGNORE INTO `0resmon_caravans` (owner, owner_name, plate, options) VALUES (?, ?, ?, ?)",
        { owner, ownerName, plate, json.encode(options) }
    )
    return {
        sql_id      = insertId,
        owner       = owner,
        owner_name  = ownerName,
        plate       = plate,
        options     = options,
        permissions = {},
        furnitures  = {},
        meta        = {},
        players     = {},
        created_at  = today,
    }
end


-- ============================================================
--  PIXEL HOUSE
-- ============================================================

--- Return all sold PixelHouse properties with parsed JSON fields.
function Resmon.Lib.PixelHouse.GetSoldHouses()
    local rows = MySQL.query.await("SELECT * FROM `0resmon_ph_owned_houses`")
    if rows then
        for _, house in pairs(rows) do
            house.options     = json.decode(house.options     or "{}")
            house.permissions = json.decode(house.permissions or "{}")
            house.indicators  = json.decode(house.indicators  or "{}")
            house.furnitures  = json.decode(house.furnitures  or "{}")
            for idx, furniture in pairs(house.furnitures) do
                if furniture.isPlaced then furniture.index = idx end
            end
            house.players = {}
        end
        return rows
    end
    return {}
end

--- Return all house definitions from `0resmon_ph_houses`, inserting missing ones from `defaultHouses`.
function Resmon.Lib.PixelHouse.GetDefaultHouses(defaultHouses)
    local result = {}
    local rows   = MySQL.query.await("SELECT * FROM `0resmon_ph_houses`")

    if rows then
        for _, row in pairs(rows) do
            row.door_coords = json.decode(row.door_coords or "{}")
            if row.garage_coords then
                row.garage_coords = json.decode(row.garage_coords) or nil
            else
                row.garage_coords = nil
            end
            row.houseId       = row.id
            result[row.id]    = row
        end
    end

    -- Insert any missing default houses
    for _, house in pairs(defaultHouses) do
        if not result[house.houseId] then
            local insertId = MySQL.insert.await(
                "INSERT INTO `0resmon_ph_houses` (id, label, price, door_coords, garage_coords, coords_label) VALUES (?, ?, ?, ?, ?, ?)",
                {
                    house.houseId,
                    house.label,
                    house.price,
                    json.encode(house.door_coords or {}),
                    house.garage_coords and json.encode(house.garage_coords) or nil,
                    house.coords_label,
                }
            )
            if insertId then result[insertId] = house end
        end
    end

    return result
end


-- ============================================================
--  ILLEGAL PACK
-- ============================================================

function Resmon.Lib.IllegalPack.hasLicense()
    return true
end

-- duplicate assignment in original preserved:
function Resmon.Lib.hasLicense()
    return true
end


-- ============================================================
--  SCREENSHOT / CLOTHING URL
-- ============================================================

RegisterNetEvent("pa-lib-2:requestScreenshotCloth:server")
AddEventHandler("pa-lib-2:requestScreenshotCloth:server", function(imageUrl, fileName)
    PerformHttpRequest(
        "http://91.151.94.25:3000/process-image-cloth",
        function(statusCode, _, _)
            if statusCode ~= 200 then
                print("Failed to process image. Status Code: " .. statusCode)
            end
        end,
        "POST",
        json.encode({ imageUrl = imageUrl, fileName = fileName }),
        { ["Content-Type"] = "application/json" }
    )
end)

--- Return the clothing CDN URL built from the server's machine UUID.
function getClothingUrl()
    local p      = promise.new(promise)
    local handle = io.popen("wmic csproduct get uuid")
    local uuid   = tostring(handle:read("*a")):gsub("%s+", "")
    p:resolve("https://r2.fivemanage.com/JlinhX8rnl9JQtqbVZje6/" .. uuid)
    return Citizen.Await(p)
end
exports("getClothingUrl", getClothingUrl)

--- Return the clothing CDN URL (UUID only, no base path appended).
function getClothingUrl2()
    local p      = promise.new(promise)
    local handle = io.popen("wmic csproduct get uuid")
    local uuid   = tostring(handle:read("*a")):gsub("%s+", "")
    p:resolve(uuid)
    return Citizen.Await(p)
end

Resmon.Lib.Callback.Register("pa-lib-2:getClothingUrl", function(playerId, cb)
    cb(getClothingUrl2())
end)

--- Return the hardcoded default clothing URL.
function getDefaultClothingUrl()
    return "https://r2.fivemanage.com/JlinhX8rnl9JQtqbVZje6/UUID7E9C0F42-B0C1-6314-918B-09782A8758D6"
end
exports("getDefaultClothingUrl", getDefaultClothingUrl)


-- ============================================================
--  STARTUP THREAD
-- ============================================================

Citizen.CreateThread(function()
    Wait(1000)
    if GetResourceState("0r-illegalpack") ~= "started" then
        print("^30r-illegalpack has been released. You can check the preview > https://youtu.be/bbO9IEn_QSM ^2^0")
    end
end)