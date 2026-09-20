local runtimeSide = IsDuplicityVersion() and 'server' or 'client'

function ConsolePrint(source, console, message)
    if console == 'server' then
        CreateThread(function()
            Citizen.Trace(message)
        end)

    elseif console == 'client' then
        if tonumber(source) and tonumber(source) > 0 then
            TriggerClientEvent('cd_bridge:ConsolePrint', tonumber(source), message)
        end

    elseif console == 'both' then
        CreateThread(function()
            Citizen.Trace(message)
        end)
        if tonumber(source) and tonumber(source) > 0 then
            TriggerClientEvent('cd_bridge:ConsolePrint', tonumber(source), message)
        end
    end
end

local function getFrameworkVersion()
    if Cfg.Framework == 'esx' then
        return GetResourceState('es_extended') == 'started' and  GetResourceMetadata('es_extended', 'version', 0) or 'unknown'
    elseif Cfg.Framework == 'qbcore' then
        return GetResourceState('qb-core') == 'started' and GetResourceMetadata('qb-core', 'version', 0) or 'unknown'
    elseif Cfg.Framework == 'qbox' then
        return GetResourceState('qbx_core') == 'started' and GetResourceMetadata('qbx_core', 'version', 0) or 'unknown'
    elseif Cfg.Framework == 'vrp' then
        return GetResourceState('vrp') == 'started' and GetResourceMetadata('vrp', 'version', 0) or 'unknown'
    else
        return 'unknown'
    end
end

local function debugPrints(source, sendToDiscord)
    local lines = {}
    local charInfo

    local function add(str)
        lines[#lines + 1] = str
    end

    add('^6-----------------------^0')
    add(('^1CODESIGN DEBUG^0 (%s - v%s - %s)'):format(GetCurrentResourceName(), GetResourceMetadata(GetCurrentResourceName(), 'version', 0), source and 'client' or 'server'))

    if source then
        local adminPerms = GetAdminPerms(source)
        local hasAdminPerms = HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'})

        add('^3PLAYER^0')
        add(('^6Source:^0 %s'):format(source))
        add(('^6Identifier:^0 %s'):format(GetIdentifier(source)))
        add(('^6Admin Perms:^0 %s'):format(type(adminPerms) == 'string' and adminPerms or json.encode(adminPerms)))
        add(('^6Has Admin Perms:^0 %s'):format(tostring(hasAdminPerms)))
        add('^6-----------------------^0')
        if not hasAdminPerms then
            add('^3PLAYER IDENTIFIERS^0')
            for i = 0, GetNumPlayerIdentifiers(source) - 1 do
                add(GetPlayerIdentifier(source, i))
            end
            add('^6-----------------------^0')
        end

        if Cfg.Framework == 'esx' or Cfg.Framework == 'qbcore' or Cfg.Framework == 'qbox' or Cfg.Framework == 'other' then
            charInfo = {
                charName = GetCharacterName(source),
                jobName = GetJobName(source),
                jobLabel = GetJobLabel(source),
                jobGrade = GetJobGrade(source),
                jobGradeLabel = GetJobGradeLabel(source),
                onDuty = GetJobDuty(source),
                gangName = GetGangName(source),
                gangLabel = GetGangLabel(source),
                gangGrade = GetGangGrade(source)
            }

            add('^3CHARACTER^0')
            add(('^6Character Name:^0 %s'):format(tostring(charInfo.charName)))
            add(('^6Job Name:^0 %s'):format(tostring(charInfo.jobName)))
            add(('^6Job Label:^0 %s'):format(tostring(charInfo.jobLabel)))
            add(('^6Job Grade:^0 %s'):format(tostring(charInfo.jobGrade)))
            add(('^6Job Grade Label:^0 %s'):format(tostring(charInfo.jobGradeLabel)))
            add(('^6On Duty:^0 %s'):format(tostring(charInfo.onDuty)))
            add(('^6Gang Name:^0 %s'):format(tostring(charInfo.gangName)))
            add(('^6Gang Label:^0 %s'):format(tostring(charInfo.gangLabel)))
            add(('^6Gang Grade:^0 %s'):format(tostring(charInfo.gangGrade)))
            add('^6-----------------------^0')
        end

        TriggerClientEvent('cd_bridge:Notification', source, 2, 'DEBUG INFO: OPEN F8 CONSOLE TO VIEW^0')
    end

    add('^3CONFIG^0')
    add(('^6Framework:^0 %s'):format(Cfg.Framework))
    add(('^6Framework Version:^0 %s'):format(getFrameworkVersion()))
    add(('^6Database:^0 %s'):format(Cfg.Database))
    add(('^6Language:^0 %s'):format(Cfg.Language))
    add('-----')
    add(('^6BridgeDebugSQL:^0 %s'):format(tostring(Cfg.BridgeDebugSQL)))
    add(('^6BridgeDebug:^0 %s'):format(tostring(Cfg.BridgeDebug)))
    add(('^6DisableDuty:^0 %s'):format(tostring(Cfg.DisableDuty)))
    add('-----')
    add(('^6Banking:^0 %s'):format(Cfg.Banking))
    add(('^6Billing:^0 %s'):format(Cfg.Billing))
    add(('^6Dispatch:^0 %s'):format(Cfg.Dispatch))
    add(('^6DrawTextUI:^0 %s'):format(Cfg.DrawTextUI))
    add(('^6Duty:^0 %s'):format(Cfg.Duty))
    add(('^6Gang:^0 %s'):format(Cfg.Gang))
    add(('^6Hud:^0 %s'):format(Cfg.Hud))
    add(('^6Inventory:^0 %s'):format(Cfg.Inventory))
    add(('^6Mechanic:^0 %s'):format(Cfg.Mechanic))
    add(('^6Notification:^0 %s'):format(Cfg.Notification))
    add(('^6PersistentVehicles:^0 %s'):format(Cfg.PersistentVehicles))
    add(('^6Phone:^0 %s'):format(Cfg.Phone))
    add(('^6Society:^0 %s'):format(Cfg.Society))
    add(('^6Target:^0 %s'):format(Cfg.Target))
    add(('^6TimeWeather:^0 %s'):format(Cfg.TimeWeather))
    add(('^6VehicleFuel:^0 %s'):format(Cfg.VehicleFuel))
    add(('^6VehicleKeys:^0 %s'):format(Cfg.VehicleKeys))
    add(('^6VehicleMileage:^0 %s'):format(Cfg.VehicleMileage))
    add(('^6VehicleShop:^0 %s'):format(Cfg.VehicleShop))
    add('^6-----------------------^0\n')

    local output = table.concat(lines, '\n')
    if charInfo then
        ConsolePrint(source, 'server', output)
        TriggerClientEvent('cd_bridge:CompareCharacterInfo', source, charInfo, output)
    else
        ConsolePrint(source, 'both', output)
    end

    if sendToDiscord then
        if not CodesignDiscordWebhook or CodesignDiscordWebhook == '' or CodesignDiscordWebhook == 'DISCORD_WEBHOOK_HERE' then
            ConsolePrint(source, 'both', '^1CodesignDiscordWebhook is not set. Please set it in the config.lua file.^0\n')
            return
        end

        local uniqueId = GenerateUniqueId()

        local data = {{
            ['color'] = 56108,
            ['title'] = GetConvar('sv_projectName', 'unknown'),
            ['description'] = string.gsub(output, '%^%d', ''),
            ['timestamp'] = os.date('!%Y-%m-%dT%H:%M:%SZ'),
            ['footer'] = {
                ['text'] = ('ID: %s'):format(uniqueId),
                ['icon_url'] = 'https://i.imgur.com/VMPGPTQ.png',
            },
        }}
        PerformHttpRequest(CodesignDiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = 'cd_bridge', embeds = data}), { ['Content-Type'] = 'application/json' })
        Wait(1000)
        ConsolePrint(source, 'both', ('\n^2===================================================^0\n^2Debug log sent to Discord (^0ID: %s^2)^0\n^2===================================================^0\n'):format(uniqueId))
    end
end

RegisterServerEvent('cd_bridge:CompareCharInfo', function(message)
    ERROR('7903', 'Character info mismatch found between server and client.\n\n'..message)
end)

RegisterCommand('debugbridge', function(source)
    local isConsole = TriggeredFromServerConsole(source)
    local isAdmin = not isConsole and HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'}) or false
    local isDebugEnabled = Cfg.BridgeDebug

    if isConsole then
        debugPrints(nil, nil)
        return
    end

    if isAdmin or isDebugEnabled then
        debugPrints(source, nil)
        return
    end

    local msg = Locale('no_debugerror_command_perms')
    ConsolePrint(source, 'both', '^1'..msg..'^0\n')
    if not isConsole then
        TriggerClientEvent('cd_bridge:Notification', source, 2, msg)
    end
end, false)

RegisterCommand('send_remote_debug_data', function(source)
    local isConsole = TriggeredFromServerConsole(source)
    local isAdmin = not isConsole and HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'}) or false
    local isDebugEnabled = Cfg.BridgeDebug

    if isConsole then
        debugPrints(nil, true)
        return
    end

    if isAdmin or isDebugEnabled then
        debugPrints(source, true)
        return
    end

    local msg = Locale('no_debugerror_command_perms')
    ConsolePrint(source, 'both', '^1'..msg..'^0\n')
    if not isConsole then
        TriggerClientEvent('cd_bridge:Notification', source, 2, msg)
    end
end, false)

RegisterCommand('bridgecommands', function(source)
    local isConsole = TriggeredFromServerConsole(source)
    local isAdmin = not isConsole and HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'}) or false
    local isDebugEnabled = Cfg.BridgeDebug

    if isConsole or isAdmin or isDebugEnabled then
        PrintDebugErrorCommands()
        return
    end

    local msg = Locale('no_debugerror_command_perms')
    ConsolePrint(source, 'both', '^1'..msg..'^0\n')
    if not isConsole then
        TriggerClientEvent('cd_bridge:Notification', source, 2, msg)
    end
end, false)

if runtimeSide == 'client' then
    RegisterCommand('debugbridgeinteractimage', function(source)
        local isAdmin = HasAdminPerms(source, {'owner', 'superadmin', 'god', 'admin', 'moderator', 'mod'}) or false
        local isDebugEnabled = Cfg.BridgeDebug

        if isAdmin or isDebugEnabled then
            TBL(exports.cd_bridge:Callback('cd_bridge:GetInteractImageData', source) or {})
            return
        end

        local msg = Locale('no_debugerror_command_perms')
        ConsolePrint(source, 'client', '^1'..msg..'^0\n')
        TriggerClientEvent('cd_bridge:Notification', source, 2, msg)
    end, false)
end