-- ┌──────────────────────────────────────────────────────────────────┐
-- │                         REMOTE ERROR LOGS                        │
-- └──────────────────────────────────────────────────────────────────┘

local caughtErrors = {}
local function storeError(error_code, origin, reason, expected_type, actual_type, value, report_type)
    local type_check = expected_type and ('%s expected, got %s : [%s]'):format(expected_type, actual_type, tostring(value)) or nil
    local callResource = GetCallResource() or 'unknown'
    local version = callResource ~= 'unknown' and GetResourceMetadata(callResource, 'version', 0) or 'unknown'
    local title = ('%s v%s - server'):format(callResource, version)

    caughtErrors[#caughtErrors + 1] = {
        error_code = error_code,
        report_type = report_type or (expected_type and 'typecheck' or 'error'),
        type_check = type_check,
        origin = origin,
        reason = reason,
        title = title,
        timestamp = os.time()
    }
    return #caughtErrors
end
exports('StoreError', storeError)
exports('GetErrors', function()
    return caughtErrors or {}
end)

local function getEarliestPlayer()
    local players = GetPlayers()
    if not players or #players == 0 then return nil end

    local earliest = nil
    local earliestId = math.huge

    for _, source in ipairs(players) do
        local id = tonumber(source)
        if id and id < earliestId then
            earliestId = id
            earliest = source
        end
    end

    return earliest
end

local function getClientErrorCodes(source)
    if not source then return {} end
    local callback = exports.cd_bridge:Callback('cd_bridge:GetClientErrorCodes', source)
    if callback == nil then
        ERROR('1203', '"cd_bridge:GetClientErrorCodes" returned nil')
        return nil
    end

    return callback
end

local reportTypes = {
    warning = {label = 'Warning', colour = '^3'},
    error = {label = 'Error', colour = '^1'},
    typecheck = {label = 'Type Check', colour = '^1'},
    autofix = {label = 'Autofix', colour = '^3'},
}

local function getReportType(err)
    return reportTypes[err.report_type] or (err.type_check and reportTypes.typecheck or reportTypes.error)
end

local function formatDiscordErrorLogWebhook(source)
    local serverErrors = exports.cd_bridge:GetErrors() or {}
    local clientErrors = getClientErrorCodes(source) or {}

    local combined = {}

    for _, err in ipairs(serverErrors) do
        combined[#combined + 1] = err
    end

    for _, err in ipairs(clientErrors) do
        combined[#combined + 1] = err
    end

    table.sort(combined, function(a, b)
        return (a.timestamp or 0) < (b.timestamp or 0)
    end)

    local lines = {}

    for _, err in ipairs(combined) do
        local reportType = getReportType(err)
        lines[#lines + 1] = ('__%s__ %s\nType: %s\nCode: **%s**%s\nOrigin: %s\n%s: %s'):format(
            err.title,
            os.date('%H:%M:%S', err.timestamp),
            reportType.label,
            tostring(err.error_code),
            (err.type_check and (' - ' .. err.type_check) or ''),
            err.origin,
            err.report_type == 'autofix' and 'Fix Applied' or 'Reason',
            err.reason
        )
    end

    return {
        description = #lines > 0 and table.concat(lines, '\n\n') or 'No errors to display',
        errorCount = {
            server = #serverErrors,
            client = #clientErrors
        }
    }
end

RegisterCommand('send_remote_error_report', function(source)
    local isConsole = TriggeredFromServerConsole(source)
    local isAdmin = not isConsole and HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'}) or false
    local isDebugEnabled = Cfg.BridgeDebug

    if not (isConsole or isAdmin or isDebugEnabled) then
        ConsolePrint(source, 'both', Locale('no_debugerror_command_perms'))
        return
    end

    if not CodesignDiscordWebhook or CodesignDiscordWebhook == '' or CodesignDiscordWebhook == 'DISCORD_WEBHOOK_HERE' then
        ConsolePrint(source, 'both', '^1CodesignDiscordWebhook is not set. Please set it in the config.lua file to enable this command.^0\n')
        return
    end

    if source == 0 then
        source = getEarliestPlayer() or nil
    end

    local webhookData = formatDiscordErrorLogWebhook(source) or {}
    if source == nil then
        if webhookData and webhookData.description and webhookData.errorCount.server > 0 then
            webhookData.description = 'No players online to retrieve error data from client. Displaying server errors only.\n\n' .. webhookData.description
        end
    end

    local errorCount = webhookData.errorCount or {client = 0, server = 0}
    local uniqueId = GenerateUniqueId()

    local data = {{
        ['color'] = 16711680,
        ['title'] = GetErrorTitle()..' : ['..GetConvar('sv_projectName', 'unknown')..']',
        ['description'] = webhookData.description,
        ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
        ['footer'] = {
            ['text'] = ('Server: %s errors | Client: %s errors | ID: %s'):format(errorCount.server, errorCount.client, uniqueId),
            ['icon_url'] = 'https://i.imgur.com/VMPGPTQ.png',
        },
    }}
    PerformHttpRequest(CodesignDiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = 'cd_bridge', embeds = data}), { ['Content-Type'] = 'application/json' })
    ConsolePrint(source, 'both', ('\n^1===================================================^0\n^1Error log sent to Discord (^0ID: %s^1)^0\n^1===================================================^0\n'):format(uniqueId))
end, false)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                        BRIDGE ERROR REPORT                       │
-- └──────────────────────────────────────────────────────────────────┘

RegisterCommand('bridgeerrorreport', function(source)
    local isConsole = TriggeredFromServerConsole(source)
    local isAdmin = not isConsole and HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'}) or false
    local isDebugEnabled = Cfg.BridgeDebug

    if not (isConsole or isAdmin or isDebugEnabled) then
        ConsolePrint(source, 'both', Locale('no_debugerror_command_perms'))
        return
    end

    local combined = {}
    local unavailable = {}
    local rows = {}
    local players = source and tonumber(source) ~= 0 and {tostring(source)} or GetPlayers() or {}

    table.sort(players, function(a, b)
        return tonumber(a) < tonumber(b)
    end)

    local function addErrors(errors, player)
        for _, err in ipairs(errors) do
            combined[#combined + 1] = {
                error = err,
                player = player,
                order = #combined + 1,
                timestamp = tonumber(err.timestamp) or 0
            }
        end
    end

    addErrors(exports.cd_bridge:GetErrors() or {})

    for _, player in ipairs(players) do
        local success, errors = pcall(function()
            return exports.cd_bridge:Callback('cd_bridge:GetClientErrorCodes', tonumber(player))
        end)

        if success and type(errors) == 'table' then
            addErrors(errors, player)
        else
            unavailable[#unavailable + 1] = player
        end
    end

    table.sort(combined, function(a, b)
        if a.timestamp == b.timestamp then return a.order < b.order end
        return a.timestamp < b.timestamp
    end)

    local header = string.rep('=', 24)..' CODESIGN CACHED ERRORS '..string.rep('=', 24)
    local maxLength = #header

    for _, entry in ipairs(combined) do
        local err = entry.error
        local reportType = getReportType(err)
        local row = {
            colour = reportType.colour,
            {'Type', reportType.label},
            {'Resource', tostring(err.title or 'unknown')},
            {'Time', os.date('%Y-%m-%d %H:%M:%S', entry.timestamp)},
            {'Side', tostring(err.side or (entry.player and 'Client' or 'Server'))},
        }

        if entry.player then
            row[#row + 1] = {'Player ID', entry.player}
        end

        row[#row + 1] = {'Code', tostring(err.error_code or 'NULL')}
        row[#row + 1] = {'Origin', tostring(err.origin or 'unknown')}
        row[#row + 1] = {err.report_type == 'autofix' and 'Fix Applied' or 'Reason', tostring(err.reason or 'No reason provided')}

        if err.type_check then
            row[#row + 1] = {'Type Check', tostring(err.type_check)}
        end

        rows[#rows + 1] = row

        for _, field in ipairs(row) do
            maxLength = math.max(maxLength, GetMaxLineLength(field[1]..': '..field[2]))
        end
    end

    local border = string.rep('=', #header)
    local output = {'', '^1'..border, '^1'..header, '^1'..border, ''}

    for _, row in ipairs(rows) do
        for _, field in ipairs(row) do
            output[#output + 1] = '    '..FormatLongText(field[1], field[2], maxLength, row.colour, row.colour)
        end
        output[#output + 1] = ''
    end

    if #combined == 0 then
        output[#output + 1] = '    ^0No cached errors to display.'
    end

    if #unavailable > 0 then
        output[#output + 1] = '    ^3Client cache unavailable for player ID(s): '..table.concat(unavailable, ', ')
    end

    output[#output + 1] = CreateFooterLine(maxLength, '=', '^1')..'^0\n'

    ConsolePrint(source, 'both', table.concat(output, '\n'))
end, false)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          PRE START CHECKS                        │
-- └──────────────────────────────────────────────────────────────────┘ 

CreateThread(function()
    Wait(2000)
    WaitForErrorHandlingToLoad()

    if Cfg == nil then
        ERROR('pre_start_checks', 'Cfg.lua Syntax Error')
    end

    if BridgeLocalesTable[Cfg.Language] == nil then
        ERROR('pre_start_checks', 'Cfg.Language or locales.lua Typo : ['..Cfg.Language..']')
    end

    if GetCurrentResourceName() ~= 'cd_bridge' then
        ERROR('pre_start_checks', 'Resource Name Changed : '..GetCurrentResourceName()..'')
    end

    if Cfg.Database ~= 'ghmattimysql' and Cfg.Database ~= 'oxmysql' and Cfg.Database ~= 'none' then
        ERROR('pre_start_checks', 'Cfg.Database Error : ['..Cfg.Database..']')
    end

    if Cfg.BridgeDebug then
        PrintDebugErrorCommands()
    end
end)