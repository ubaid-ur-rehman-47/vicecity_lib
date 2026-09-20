local SIDE = IsDuplicityVersion() and 'server' or 'client'
local resourceName = GetCurrentResourceName()
local docsLink = 'https://docs.codesign.pro'
local discordLink = 'https://discord.gg/codesign'

ErrorHandlingCodeLoaded = nil

local function stripColors(str)
    return str:gsub('%^%d', '')
end

function GetCallOrigin()
    local info = debug.getinfo(3, 'Sl')
    if not info then return ('@%s:unknown:0'):format(resourceName) end
    return (info.short_src or ('@%s:unknown'):format(resourceName)) .. ':' .. (info.currentline or '0')
end

function GetCallResource()
    local invoking = GetInvokingResource()
    if invoking then return invoking end

    local info = debug.getinfo(3, 'Sl')
    if info and info.short_src then
        local resource = info.short_src:match('^@([^/]+)/')
        if resource then return resource end
    end

    return Locale('unknown')
end

function GetMaxLineLength(...)
    local max = 0

    for _, str in ipairs({...}) do
        str = tostring(str or '')
        local clean = stripColors(str)
        local len = #clean
        if len > max then
            max = len
        end
    end

    if max < 20 then
        max = 20
    elseif max > 80 then
        max = 80
    end

    return max
end

function GetErrorTitle(side, errorCount)
    if errorCount then
        return ('[%s v%s - %s - #%s]'):format(resourceName, GetResourceMetadata(resourceName, 'version', 0), side, errorCount or '')
    else
        return ('[%s v%s - %s]'):format(resourceName, GetResourceMetadata(resourceName, 'version', 0), side)
    end
end

function CreateHeaderLine(side, max_length, errorCount)
    local title = GetErrorTitle(side, errorCount)
    local content_length = #title

    if content_length >= max_length then
        max_length = content_length + 2
    end

    local side_length = math.floor((max_length - content_length) / 2)
    local left = string.rep('=', side_length)
    local right = string.rep('=', max_length - content_length - side_length)

    return ('^0%s%s%s^0'):format(left, title, right)
end

function CreateFooterLine(length, char, colour)
    char = char or '='
    colour = colour or '^0'

    if length < 1 then length = 1 end

    local version = GetResourceMetadata('cd_bridge', 'version', 0) or Locale('unknown')
    local text = (' cd_bridge v%s '):format(version)
    local textLength = #text

    if textLength >= length then
        return ('%s%s^0'):format(colour, text)
    end

    local remaining = length - textLength
    local left = math.floor(remaining / 2)
    local right = remaining - left

    return ('%s%s%s%s^0'):format(
        colour,
        string.rep(char, left),
        text,
        string.rep(char, right)
    )
end

function FormatLongText(label, text, maxLength, labelColour, textColour)
    label = tostring(label)
    text = tostring(text)
    labelColour = labelColour or '^0'
    textColour = textColour or '^0'

    local prefix = label..': '
    local firstLineLength = maxLength - #prefix
    local nextLineLength = maxLength - #prefix
    local lines = {}

    for textLine in (text..'\n'):gmatch('(.-)\n') do
        local leadingWhitespace = textLine:match('^(%s*)') or ''
        local remainingText = textLine:sub(#leadingWhitespace + 1)

        local currentLine = leadingWhitespace
        local firstWord = true

        for word in remainingText:gmatch('%S+') do
            local limit = #lines == 0 and firstLineLength or nextLineLength

            if firstWord then
                currentLine = currentLine..word
                firstWord = false
            elseif #currentLine + #word + 1 <= limit then
                currentLine = currentLine..' '..word
            else
                lines[#lines + 1] = currentLine
                currentLine = word
            end
        end

        if currentLine ~= '' then
            lines[#lines + 1] = currentLine
        end
    end

    local output = labelColour..prefix..textColour..(lines[1] or '')

    for i = 2, #lines do
        output = output..'\n    '..string.rep(' ', #prefix)..textColour..lines[i]
    end

    return output
end

function WARN(error_code, reason)
    error_code = error_code and tostring(error_code) or 'NULL'
    local origin = GetCallOrigin() or Locale('unknown')
    reason = reason and tostring(reason) or Locale('no_reason_provided')

    local errorCount = exports.cd_bridge:StoreError(error_code, origin, reason, nil, nil, nil, 'warning')

    local line1 = string.format('^3%s: %s', Locale('type'), Locale('warning'))
    local line2 = string.format('^3%s: %s', Locale('code'), error_code)
    local line3 = string.format('^3%s: %s', Locale('origin'), origin)
    local line4 = string.format('^3%s: %s', Locale('reason'), reason)
    local line5 = string.format('^3%s', Locale('warning_status'))
    local line6 = string.format('^2%s?', Locale('need_support'))
    local line7 = string.format('^0%s: ^5%s.', Locale('documentation'), discordLink)
    local line8 = string.format('^0%s: ^5%s.', Locale('discord'), discordLink)

    local maxLength = GetMaxLineLength(line4)
    local fixedLinesMaxLength = GetMaxLineLength(line1, line2, line3, line5, line6, line7, line8)
    if fixedLinesMaxLength > maxLength then
        maxLength = fixedLinesMaxLength
    end
    line4 = FormatLongText(Locale('reason'), reason, maxLength, '^3', '^3')

    Citizen.Trace(([[

    ^0%s
    %s
    %s
    %s
    %s

    %s

    %s
    %s
    %s
    ^0%s

    ]] .. '^0\n'):format(
        CreateHeaderLine(SIDE, maxLength, errorCount),
        line1,
        line2,
        line3,
        line4,
        line5,
        line6,
        line7,
        line8,
        CreateFooterLine(maxLength)
    ))
end

function ERROR(error_code, reason)
    error_code = error_code and tostring(error_code) or 'NULL'
    local origin = GetCallOrigin() or Locale('unknown')
    reason = reason and tostring(reason) or Locale('no_reason_provided')

    local errorCount = exports.cd_bridge:StoreError(error_code, origin, reason, nil, nil, nil, 'error')

    local line1 = string.format('^1%s: %s', Locale('type'), Locale('error'))
    local line2 = string.format('^1%s: %s', Locale('code'), error_code)
    local line3 = string.format('^1%s: %s', Locale('origin'), origin)
    local line4 = string.format('^1%s: %s', Locale('reason'), reason)
    local line5 = string.format('^1%s', Locale('error_status'))
    local line6 = string.format('^2%s?', Locale('need_support'))
    local line7 = string.format('^0%s: ^5%s.', Locale('documentation'), discordLink)
    local line8 = string.format('^0%s: ^5%s.', Locale('discord'), discordLink)

    local maxLength = GetMaxLineLength(line4)
    local fixedLinesMaxLength = GetMaxLineLength(line1, line2, line3, line5, line6, line7, line8)
    if fixedLinesMaxLength > maxLength then
        maxLength = fixedLinesMaxLength
    end
    line4 = FormatLongText(Locale('reason'), reason, maxLength, '^1', '^1')

    Citizen.Trace(([[

    ^0%s
    %s
    %s
    %s
    %s

    %s

    %s
    %s
    %s
    ^0%s

    ]] .. '^0\n'):format(
        CreateHeaderLine(SIDE, maxLength, errorCount),
        line1,
        line2,
        line3,
        line4,
        line5,
        line6,
        line7,
        line8,
        CreateFooterLine(maxLength)
    ))
end

function TYPECHECK(value, expected_type, error_code, reason)
    local actual_type = type(value)
    if actual_type == expected_type then return true end

    error_code = error_code and tostring(error_code) or 'NULL'
    local origin = GetCallOrigin() or Locale('unknown')
    value = tostring(value)
    reason = reason and tostring(reason) or Locale('no_reason_provided')

    local errorCount = exports.cd_bridge:StoreError(error_code, origin, reason, expected_type, actual_type, value, 'typecheck')

    local line1 = string.format('^1%s: %s', Locale('type'), Locale('error'))
    local line2 = string.format('^1%s: %s', Locale('code'), error_code)
    local line3 = string.format('^1%s: %s', Locale('origin'), origin)
    local line4 = string.format('^1%s: %s', Locale('reason'), reason)
    local line5 = string.format('^1( %s expected, got %s : [%s] )', expected_type, actual_type, value)
    local line6 = string.format('^1%s', Locale('error_status'))
    local line7 = string.format('^2%s?', Locale('need_support'))
    local line8 = string.format('^0%s: ^5%s.', Locale('documentation'), discordLink)
    local line9 = string.format('^0%s: ^5%s.', Locale('discord'), discordLink)

    local maxLength = GetMaxLineLength(line4)
    local fixedLinesMaxLength = GetMaxLineLength(line1, line2, line3, line5, line6, line7, line8, line9)
    if fixedLinesMaxLength > maxLength then
        maxLength = fixedLinesMaxLength
    end
    line4 = FormatLongText(Locale('reason'), reason, maxLength, '^1', '^1')

    Citizen.Trace(([[

    ^0%s
    %s
    %s
    %s
    %s
    %s

    %s

    %s
    %s
    %s
    ^0%s

    ]] .. '^0\n'):format(
        CreateHeaderLine(SIDE, maxLength, errorCount),
        line1,
        line2,
        line3,
        line4,
        line5,
        line6,
        line7,
        line8,
        line9,
        CreateFooterLine(maxLength)
    ))
    return false
end
function TypeCheck(value, expected_type, error_code, reason)
    return TYPECHECK(value, expected_type, error_code, reason)
end

function AUTOFIX(fixApplied)
    local origin = GetCallOrigin() or Locale('unknown')
    fixApplied = fixApplied and tostring(fixApplied) or Locale('unknown')

    local errorCount = exports.cd_bridge:StoreError('AUTOFIX', origin, fixApplied, nil, nil, nil, 'autofix')

    local line1 = string.format('^3%s: %s', Locale('type'), Locale('autofix'))
    local line2 = string.format('^3%s: %s', Locale('origin'), origin)
    local line3 = string.format('^3%s', Locale('autofix_status'))
    local line4 = string.format('^3%s: %s', Locale('fix_applied'), fixApplied)

    local maxLength = GetMaxLineLength(line4)
    local fixedLinesMaxLength = GetMaxLineLength(line1, line2, line3)
    if fixedLinesMaxLength > maxLength then
        maxLength = fixedLinesMaxLength
    end
    line4 = FormatLongText(Locale('fix_applied'), fixApplied, maxLength, '^3', '^3')

    Citizen.Trace(([[

    ^0%s
    %s
    %s
    %s

    %s
    ^0%s

    ]] .. '^0\n'):format(
        CreateHeaderLine(SIDE, maxLength, errorCount),
        line1,
        line2,
        line3,
        line4,
        CreateFooterLine(maxLength)
    ))
end



ErrorHandlingCodeLoaded = true

function HasErrorHandlingCodeLoaded()
    if not ErrorHandlingCodeLoaded then return false end

    local success, errors = pcall(function()
        return exports.cd_bridge:GetErrors()
    end)
    return success and type(errors) == 'table'
end

function WaitForErrorHandlingToLoad()
    if HasErrorHandlingCodeLoaded() then return true end

    local errorHandlingLoadStartTime = GetGameTimer()
    local nextErrorHandlingWarning = 20000
    local errorHandlingLoadWarningShown = false

    while not HasErrorHandlingCodeLoaded() do
        Wait(0)

        local elapsed = GetGameTimer() - errorHandlingLoadStartTime

        if elapsed >= nextErrorHandlingWarning then
            if WARN then
                WARN('Waiting for error handling and the StoreError export. Elapsed loading time: '..math.floor(elapsed / 1000)..' seconds')
            else
                Citizen.Trace('^3[cd_bridge WARNING 0002] Waiting for error handling and the StoreError export. Elapsed loading time: '..math.floor(elapsed / 1000)..' seconds^0\n')
            end
            errorHandlingLoadWarningShown = true
            nextErrorHandlingWarning = nextErrorHandlingWarning + 10000
        end
    end

    if errorHandlingLoadWarningShown then
        local totalElapsed = GetGameTimer() - errorHandlingLoadStartTime
        AUTOFIX('The error handling code has finished loading. Total loading time: '..math.floor(totalElapsed / 1000)..' seconds')
    end

    return true
end