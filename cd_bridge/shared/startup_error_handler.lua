local isBridge = GetCurrentResourceName() == 'cd_bridge'

if not isBridge then
    if BridgeStartupReporterInstalled then return end
    BridgeStartupReporterInstalled = true

    local pendingErrors = {}
    local reportedErrors = {}
    local resourceName = GetCurrentResourceName()
    local delivering = false

    function BridgeReportStartupError(message, file)
        local traceback = tostring(message)
        local key = tostring(file or '')..'\n'..traceback

        if not reportedErrors[key] then
            reportedErrors[key] = true
            pendingErrors[#pendingErrors + 1] = { traceback = traceback, file = file }
        end

        if not delivering and #pendingErrors > 0 then
            delivering = true
            Citizen.CreateThread(function()
                local warningShown = false
                while #pendingErrors > 0 do
                    local entry = pendingErrors[1]
                    local success, accepted = pcall(function()
                        return exports.cd_bridge:ReportStartupError(resourceName, entry.traceback, entry.file)
                    end)
                    if success and accepted then
                        table.remove(pendingErrors, 1)
                        warningShown = false
                    elseif not warningShown then
                        warningShown = true
                        ERROR('2312', ('[cd_bridge] Startup error delivery pending: %s\n%s'):format(success and 'collector did not acknowledge the error' or tostring(accepted), entry.traceback))
                    end
                    if #pendingErrors > 0 then Wait(100) end
                end
                delivering = false
            end)
        end
        return traceback
    end

    function BridgeStartupErrorHandler(err, file)
        return BridgeReportStartupError(debug.traceback(tostring(err), 2), file)
    end

    return
end


local docsLink = 'https://docs.codesign.pro'
local discordLink = 'https://discord.gg/codesign'
local InitialCheckComplete = false
local StartupErrors = {}
local CachedStartupErrors = {}
local BridgeStartupFailed = false
local ClosedChecks = {}
local ResourceGeneration = {}
local runtimeSide = IsDuplicityVersion() and 'server' or 'client'
local printStartupReport

local function normalizeFilePath(resource, file)
    if not file then return nil end

    file = file:gsub('\\', '/')
    file = file:gsub('^@+', '')
    file = file:gsub('^/+', '')

    local prefix = resource..'/'

    if file:sub(1, #prefix) == prefix then
        file = file:sub(#prefix + 1)
    end

    return file
end

local function collectStartupError(resource, traceback, file)
    if BridgeStartupFailed and resource ~= 'cd_bridge' and type(traceback) == 'string' then
        return true
    end

    if (resource ~= 'cd_bridge' and not (DependantResources or {})[resource]) or type(traceback) ~= 'string' then
        return false
    end

    if resource == 'cd_bridge' and not BridgeStartupFailed then
        BridgeStartupFailed = true
        CachedStartupErrors = {}
        for pendingResource in pairs(StartupErrors) do
            if pendingResource ~= 'cd_bridge' then
                StartupErrors[pendingResource] = nil
            end
        end
    end

    local errors = StartupErrors[resource] or {}
    StartupErrors[resource] = errors

    file = type(file) == 'string' and file or traceback:match('@([^\n]-):%d+:') or traceback:match('^([^\n]-):%d+:') or 'startup callback'
    file = normalizeFilePath(resource, file)

    for _, entry in ipairs(errors) do
        if entry.error == traceback and entry.file == file then
            return true
        end
    end

    errors[#errors + 1] = { resource = resource, side = runtimeSide, file = file, error = traceback }

    if ClosedChecks[resource] then
        printStartupReport({ errors[#errors] })
    end

    return true
end

function BridgeReportStartupError(message, file)
    local traceback = tostring(message)
    collectStartupError('cd_bridge', traceback, file)
    return traceback
end

function BridgeStartupErrorHandler(err, file)
    return BridgeReportStartupError(debug.traceback(tostring(err), 2), file)
end

exports('ReportStartupError', function(resource, traceback, file)
    local invoking = GetInvokingResource()
    if invoking and invoking ~= resource then
        return false
    end
    return collectStartupError(resource, traceback, file)
end)

local function clearResourceData(resource)
    StartupErrors[resource] = nil
    for index = #CachedStartupErrors, 1, -1 do
        if CachedStartupErrors[index].resource == resource then
            table.remove(CachedStartupErrors, index)
        end
    end
    ClosedChecks[resource] = nil
    ResourceGeneration[resource] = (ResourceGeneration[resource] or 0) + 1
end

local function stripColors(str)
    return str:gsub('%^%d', '')
end

local function displayError(message)
    return (tostring(message):gsub('[\r\n]+%s*stack traceback:.*$', ''))
end

local function printErrors(errors)
    if #errors == 0 then return end

    local headerTitle = Locale('script_file_errors')
    local headerSide = string.rep('=', 24)
    local header = headerSide..' '..headerTitle..' '..headerSide
    local maxLength = #stripColors(header)
    local rows = {}

    for _, errorData in ipairs(errors) do
        local row = {
            { Locale('resource'), errorData.resource },
            { Locale('file'), errorData.file },
            { Locale('error'), displayError(errorData.error) },
        }
        rows[#rows + 1] = row
        for _, field in ipairs(row) do
            maxLength = math.max(maxLength, GetMaxLineLength(('^1%s: %s'):format(field[1], field[2])))
        end
    end

    local output = {}
    for _, row in ipairs(rows) do
        local lines = {}
        for _, field in ipairs(row) do
            lines[#lines + 1] = '    '..FormatLongText(field[1], field[2], maxLength, '^1', '^1')
        end
        output[#output + 1] = table.concat(lines, '\n')
    end

    local fullHeaderLine = string.rep('=', #stripColors(header))

    Citizen.Trace(([[

^1%s
^1%s
^1%s

%s

    ^2%s?
    ^0%s: ^5%s.
    ^0%s: ^5%s.
^1%s
    ]] .. '^0\n'):format(
        fullHeaderLine,
        header,
        fullHeaderLine,
        table.concat(output, '\n\n'),
        Locale('need_support'),
        Locale('documentation'),
        docsLink,
        Locale('discord'),
        discordLink,
        CreateFooterLine(maxLength, '=', '^1')
    ))
end

local function finishResourceCheck(errors, resource)
    for _, entry in ipairs(StartupErrors[resource] or {}) do
        errors[#errors + 1] = entry
    end

    StartupErrors[resource] = nil
    ClosedChecks[resource] = true
end

function printStartupReport(errors, replay)
    if not replay then
        for _, entry in ipairs(errors) do
            CachedStartupErrors[#CachedStartupErrors + 1] = entry
        end
    end

    local success, reason = pcall(printErrors, errors)

    if success then
        return
    end

    ERROR('7566',  ('[cd_bridge] Startup report formatting failed: %s'):format(tostring(reason)))

    for _, entry in ipairs(errors) do
        ERROR('9873', ('[cd_bridge] Startup report entry: %s (%s) %s\n%s'):format(
            entry.resource,
            entry.side,
            entry.file,
            displayError(entry.error)
        ))
    end
end

if runtimeSide == 'server' then
    RegisterCommand('showstartuperrors', function(source)
        if source ~= 0 then return end

        if #CachedStartupErrors == 0 then
            DEBUG('No cached startup errors.')
            return
        end

        printStartupReport(CachedStartupErrors, true)
    end, false)
end

CreateThread(function()
    Wait(5000)

    local errors = {}

    finishResourceCheck(errors, 'cd_bridge')

    for resource in pairs(DependantResources or {}) do
        if resource ~= 'cd_bridge' and GetResourceState(resource) == 'started' then
            finishResourceCheck(errors, resource)
        end
    end

    printStartupReport(errors)

    InitialCheckComplete = true
end)

AddEventHandler('onResourceStarting', function(resource)
    if not (DependantResources or {})[resource] then
        return
    end

    clearResourceData(resource)
end)

AddEventHandler(runtimeSide == 'server' and 'onResourceStop' or 'onClientResourceStop', function(resource)
    if not (DependantResources or {})[resource] then
        return
    end

    clearResourceData(resource)
end)

AddEventHandler(runtimeSide == 'server' and 'onResourceStart' or 'onClientResourceStart', function(resource)
    if not InitialCheckComplete then
        return
    end

    if not (DependantResources or {})[resource] then
        return
    end

    local generation = ResourceGeneration[resource]

    CreateThread(function()
        Wait(5000)

        if GetResourceState(resource) ~= 'started' or ResourceGeneration[resource] ~= generation then
            return
        end

        local errors = {}

        finishResourceCheck(errors, resource)
        printStartupReport(errors)
    end)
end)
