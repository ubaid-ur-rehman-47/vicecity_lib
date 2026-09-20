local SIDE = IsDuplicityVersion() and 'server' or 'client'

function PrintDebugErrorCommands()
    local title = Locale('debug_error_commands')
    local serverOnly = Locale('command_list_server_only')
    local serverClient = Locale('command_list_server_client')
    local clientOnly = Locale('command_list_client_only')

    local sections = {
        {
            title = Locale('command_list_error_handling'),
            commands = {
                {'showstartuperrors', serverOnly, Locale('command_list_show_startup_errors')},
                {'bridgeerrorreport', serverClient, Locale('command_list_bridge_error_report')},
                {'send_remote_error_report', serverClient, Locale('command_list_send_remote_error_report')},
            }
        },
        {
            title = Locale('command_list_debug'),
            commands = {
                {'debugbridge', serverClient, Locale('command_list_debugbridge')},
                {'debugbridgeinteractimage', clientOnly, Locale('command_list_debugbridgeinteractimage')},
                {'send_remote_debug_data', serverClient, Locale('command_list_send_remote_debug_data')},
            }
        },
        {
            title = Locale('command_list_other'),
            commands = {
                {'closenui', clientOnly, Locale('command_list_closenui')},
                {'bridgecommands', serverClient, Locale('command_list_bridgecommands')},
            }
        }
    }

    local commandWidth = 0
    local sideWidth = 0

    for _, section in ipairs(sections) do
        for _, command in ipairs(section.commands) do
            commandWidth = math.max(commandWidth, #command[1])
            sideWidth = math.max(sideWidth, #command[2] + 2)
        end
    end

    local function formatCommand(command, side, description)
        local sideText = '['..side..']'
        return string.format(' ^3%-'..commandWidth..'s ^0%-'..sideWidth..'s %s', command, sideText, description)
    end

    local maxLength = GetMaxLineLength(title)

    for _, section in ipairs(sections) do
        maxLength = math.max(maxLength, GetMaxLineLength(section.title..':'))

        for _, command in ipairs(section.commands) do
            maxLength = math.max(maxLength, GetMaxLineLength(formatCommand(command[1], command[2], command[3])))
        end
    end

    local titleText = ' '..title..' '
    local remaining = math.max(0, maxLength - #titleText)
    local left = math.floor(remaining / 2)
    local right = remaining - left
    local header = '^3'..string.rep('=', left)..titleText..string.rep('=', right)

    local output = {
        header
    }

    for sectionIndex, section in ipairs(sections) do
        output[#output + 1] = '^3'..section.title..':'

        for _, command in ipairs(section.commands) do
            output[#output + 1] = formatCommand(command[1], command[2], command[3])
        end

        if sectionIndex < #sections then
            output[#output + 1] = ''
        end
    end

    output[#output + 1] = CreateFooterLine(maxLength, '=', '^3')..'^0\n'

    Citizen.Trace(table.concat(output, '\n'))
end

function DEBUG(message)
    local origin = GetCallOrigin() or Locale('unknown')
    message = message and tostring(message) or Locale('unknown')

    local line1 = string.format('^6%s: %s', Locale('type'), Locale('debug'))
    local line2 = string.format('^6%s: %s', Locale('origin'), origin)
    local line3 = string.format('^6%s', Locale('debug_status'))
    local line4 = string.format('^6%s: ^3%s', Locale('message'), message)

    local maxLength = GetMaxLineLength(line4)
    local fixedLinesMaxLength = GetMaxLineLength(line1, line2, line3)
    if fixedLinesMaxLength > maxLength then
        maxLength = fixedLinesMaxLength
    end
    line4 = FormatLongText(Locale('message'), message, maxLength, '^6', '^3')

    Citizen.Trace(([[

    ^0%s
    %s
    %s
    %s

    %s
    ^0%s

    ]] .. '^0\n'):format(
        CreateHeaderLine(SIDE, maxLength),
        line1,
        line2,
        line3,
        line4,
        CreateFooterLine(maxLength)
    ))
end
