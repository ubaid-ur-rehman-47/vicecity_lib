-- Table debug print.
function TBL(t, src)
    src = type(src) == 'number' and src or nil
    if GetResourceState('cd_devtools') == 'started' then
        TriggerClientEvent('table', src or -1, t)
    else
        print(json.encode(t, { indent = true }))
    end
end

-- Check whether a source is from a player or server console.
function TriggeredFromServerConsole(source)
    return source == nil or source == '' or source == 0 or type(source) ~= 'number'
end

-- Notification wrapper.
function Notif(source, action, locale_key, ...)
    if not TypeCheck(source, 'number', '3000', 'source missing from Notif function, 1st arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    if not TypeCheck(action, 'number', '3001', 'action missing from Notif function, 2nd arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    if action < 1 or action > 3 then
        return ERROR('3002', 'action not valid in Notif function, 2nd arg: '..tostring(action)..'. Locale Key: '..(locale_key or 'nil'))
    end

    if not TypeCheck(locale_key, 'string', '3002', 'locale_key missing from Notif function, 3rd arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    local preferred = tostring(Cfg.Language):upper()

    local function getFromOneTable(tbl, langKey)
        if not tbl then return nil end
        if tbl[langKey] and tbl[langKey][locale_key] then
            return tbl[langKey][locale_key]
        end
        return nil
    end

    local function findTemplate(langKey)
        return getFromOneTable(LocalesTable, langKey) or getFromOneTable(Locales, langKey) or getFromOneTable(BridgeLocalesTable, langKey)
    end

    local template = findTemplate(preferred)

    if not template and preferred ~= 'EN' then
        template = findTemplate('EN')
    end

    if not template then
        return ERROR('3003', 'locale not found in any locale table: '..(locale_key or 'nil')..' (lang tried: '..preferred..' -> EN)')
    end

    local message = template

    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, template, ...)
        if not ok then
            return ERROR('3004', 'Format failed for key: ' .. (locale_key or 'nil'))
        end
        message = formatted
    end

    local ok, err = pcall(function()
        local title = Locale(GetCurrentResourceName() ~= 'cd_bridge' and GetCurrentResourceName() or 'title')
        TriggerClientEvent('cd_bridge:Notification', source, action, message, title)
    end)
    if not ok then
        return ERROR('3005', 'Notification failed: ' .. tostring(err))
    end
end

-- Attempts to json encode a table, but returns nil if the table is empty or nil.
function EncodeOrNil(value)
    if value == nil then
        return nil
    end

    if type(value) == 'table' then
        if next(value) == nil then
            return nil
        end
        return json.encode(value)
    end

    return value
end

-- Trigger our own event when txadmin is restarting server.
if GetCurrentResourceName() == 'cd_bridge' then
    AddEventHandler('txAdmin:events:scheduledRestart', function(eventData)
        if eventData.secondsRemaining == 60 then
            TriggerEvent('cd_bridge:ServerRestarting', eventData.secondsRemaining)
            TriggerClientEvent('cd_bridge:ServerRestarting', -1, eventData.secondsRemaining)
        end
    end)

    AddEventHandler('txAdmin:events:serverShuttingDown', function(eventData)
        TriggerEvent('cd_bridge:ServerRestarting', 0)
        TriggerClientEvent('cd_bridge:ServerRestarting', -1, 0)
    end)
end

-- Returns all online players of the same job in a table.
function GetAllOnlinePlayersWithSameJob(job)
    local players = {}
    for _, src in pairs(GetPlayers() or {}) do
        local src = tonumber(src)
        local playerJob = GetJobName(src)
        if playerJob == job then
            players[#players+1] = src
        end
    end
    return players
end

-- Get source and character name of players within distance.
function GetClosestPlayersCharacterInfo(source, dataRetrieval, includeSelf, distance)
    local players = {}

    source = tonumber(source)
    distance = tonumber(distance) or 10.0

    if not source then return players end

    local myPed = GetPlayerPed(source)
    if not myPed or myPed == 0 then return players end

    local myCoords = GetEntityCoords(myPed)

    for _, playerSrc in ipairs(GetPlayers()) do
        playerSrc = tonumber(playerSrc)

        if playerSrc and (includeSelf or playerSrc ~= source) then
            local playerPed = GetPlayerPed(playerSrc)

            if playerPed and playerPed ~= 0 then
                local playerCoords = GetEntityCoords(playerPed)

                if #(myCoords - playerCoords) <= distance then
                    local player = {}

                    if dataRetrieval == 'both' or dataRetrieval == 'source' then
                        player.source = playerSrc
                    end

                    if dataRetrieval == 'both' or dataRetrieval == 'charname' then
                        player.name = GetCharacterName(playerSrc)
                    end

                    players[#players + 1] = player
                end
            end
        end
    end

    return next(players) and players or nil
end

-- Get source and character name of all players.
function GetAllPlayersCharacterInfo(source, dataRetrieval, includeSelf)
    local players = {}

    source = tonumber(source)

    for _, playerSrc in ipairs(GetPlayers()) do
        playerSrc = tonumber(playerSrc)

        if playerSrc and (includeSelf or playerSrc ~= source) then
            local player = {}

            if dataRetrieval == 'both' or dataRetrieval == 'source' then
                player.source = playerSrc
            end

            if dataRetrieval == 'both' or dataRetrieval == 'charname' then
                player.name = GetCharacterName(playerSrc)
            end

            players[#players + 1] = player
        end
    end
    return next(players) and players or nil
end

-- Check if the given source is valid. Returns true if the source is a number, false otherwise.
function IsSourceValid(source)
    if not source or type(source) ~= 'number' then
        return false
    end

    return true
end

-- To keep backwards compatibility with older scripts that call CheckAllItemsExist directly.
if GetCurrentResourceName() ~= 'cd_bridge' then
    function CheckAllItemsExist(needed)
        TriggerEvent('cd_bridge:CheckAllItemsExist', needed)
    end
end