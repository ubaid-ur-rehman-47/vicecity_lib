local githubURL = {
    ['cd_bridge'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_bridge.txt',
    ['cd_cctv'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_cctv.txt',
    ['cd_dispatch3d'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_dispatch3d.txt',
    ['cd_doorlock'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_doorlock.txt',
    ['cd_eventcalendar'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_eventcalendar.txt',
    ['cd_garage'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_garage.txt',
    ['cd_mechanic'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_mechanic.txt',
    ['cd_mechanicprops'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_mechanicprops.txt',
    ['cd_torquemaster'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_torquemaster.txt',
    ['cd_vipshop'] = 'https://raw.githubusercontent.com/RampBST/Codesign_Versions_V2/main/cd_vipshop.txt'
}

local githubFallbackURL = 'https://cdn.jsdelivr.net/gh/RampBST/Codesign_Versions_V2@main/%s.txt'

local versionRequestHeaders = {
    ['Accept'] = 'application/json',
    ['User-Agent'] = 'cd_bridge-version-check'
}

local docsLinks = {
    ['cd_bridge'] = 'https://docs.codesign.pro/paid-scripts/bridge/changelog',
    ['cd_cctv'] = 'https://docs.codesign.pro/paid-scripts/cctv-cameras/changelog',
    ['cd_dispatch3d'] = 'https://docs.codesign.pro/paid-scripts/dispatch3d/changelog',
    ['cd_doorlock'] = 'https://docs.codesign.pro/paid-scripts/doorlock/changelog',
    ['cd_eventcalendar'] = 'https://docs.codesign.pro/paid-scripts/eventcalendar/changelog',
    ['cd_garage'] = 'https://docs.codesign.pro/paid-scripts/garage/changelog',
    ['cd_mechanic'] = 'https://docs.codesign.pro/paid-scripts/mechanic/changelog',
    ['cd_mechanicprops'] = 'N/A',
    ['cd_torquemaster'] = 'N/A',
    ['cd_vipshop'] = 'https://docs.codesign.pro/paid-scripts/vipshop/changelog',
}

local downloadLinks = {
    ['cd_bridge'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_bridge',
    ['cd_cctv'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_cctv',
    ['cd_dispatch3d'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_dispatch3d',
    ['cd_doorlock'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_doorlock',
    ['cd_eventcalendar'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_eventcalendar',
    ['cd_garage'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_garage',
    ['cd_mechanic'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_mechanic',
    ['cd_mechanicprops'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_mechanicprops',
    ['cd_torquemaster'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_torquemaster',
    ['cd_vipshop'] = 'https://portal.cfx.re/assets/granted-assets?search=cd_vipshop',
}

local VersionCheckQueue = {
    updates = {},
    betas = {},
    errors = {}
}

local VERSION_CHECK_LINE_WIDTH = 83
local VERSION_CHECK_LABEL_MIN_WIDTH = 11

local InitialVersionCheckRunning = true
local versionCheckPrintScheduled = false
local VersionCheckInProgress = {}

local function ParseVersion(version)
    version = tostring(version or ''):gsub('%s+', '')

    local major, minor, patch, suffix = version:match('^(%d+)%.(%d+)%.(%d+)%.?([A-Za-z]*)$')
    if not major then return nil end

    suffix = suffix or ''

    return {
        major = tonumber(major),
        minor = tonumber(minor),
        patch = tonumber(patch),
        suffix = suffix,
        display_suffix = suffix ~= '' and '.'..suffix or '',
        raw = version
    }
end

local function IsBetaVersion(versionData)
    return versionData and tostring(versionData.suffix or ''):lower() == 'beta'
end

local function CompareVersions(new, current)
    if new.major > current.major then return true elseif new.major < current.major then return false end
    if new.minor > current.minor then return true elseif new.minor < current.minor then return false end
    if new.patch > current.patch then return true elseif new.patch < current.patch then return false end

    return false
end

local function FormatVersion(currentVersionData, latestVersionData)
    local current_table = {
        currentVersionData.major,
        currentVersionData.minor,
        currentVersionData.patch
    }

    local new_table = {
        latestVersionData.major,
        latestVersionData.minor,
        latestVersionData.patch
    }

    local formatted_current_version, formatted_new_version = '', ''

    for c, d in ipairs(current_table) do
        if d == new_table[c] then
            formatted_current_version = formatted_current_version..'^5'..d..'.^0'
            formatted_new_version = formatted_new_version..'^5'..new_table[c]..'.^0'
        else
            formatted_current_version = formatted_current_version..'^1'..d..'^5.^0'
            formatted_new_version = formatted_new_version..'^2'..new_table[c]..'^5.^0'
        end
    end

    formatted_current_version = formatted_current_version:sub(1, -4)..currentVersionData.display_suffix
    formatted_new_version = formatted_new_version:sub(1, -4)..latestVersionData.display_suffix

    return formatted_current_version, formatted_new_version
end

local function FormatReleaseDate(releaseDate)
    if type(releaseDate) ~= 'table' then
        return Locale('unknown')
    end

    local days = math.floor(os.difftime(os.time(), os.time{
        day = releaseDate.day,
        month = releaseDate.month,
        year = releaseDate.year
    }) / 86400)

    if days == 0 then
        return Locale('today')
    elseif days == 1 then
        return Locale('yesterday')
    end

    return Locale('days_ago', days)
end

local function IsZeroWidthCodepoint(codepoint)
    return (codepoint >= 0x0300 and codepoint <= 0x036F)
        or (codepoint >= 0x0483 and codepoint <= 0x0489)
        or (codepoint >= 0x0610 and codepoint <= 0x061A)
        or (codepoint >= 0x064B and codepoint <= 0x065F)
        or codepoint == 0x0670
        or (codepoint >= 0x06D6 and codepoint <= 0x06ED)
        or (codepoint >= 0x0900 and codepoint <= 0x0903)
        or (codepoint >= 0x093A and codepoint <= 0x094F)
        or (codepoint >= 0x0951 and codepoint <= 0x0957)
        or (codepoint >= 0x0962 and codepoint <= 0x0963)
        or (codepoint >= 0x200B and codepoint <= 0x200F)
        or (codepoint >= 0x202A and codepoint <= 0x202E)
        or (codepoint >= 0x2060 and codepoint <= 0x206F)
        or (codepoint >= 0xFE00 and codepoint <= 0xFE0F)
        or (codepoint >= 0xFE20 and codepoint <= 0xFE2F)
        or codepoint == 0xFEFF
end

local function IsWideCodepoint(codepoint)
    return codepoint >= 0x1100 and (
        codepoint <= 0x115F
        or codepoint == 0x2329
        or codepoint == 0x232A
        or (codepoint >= 0x2E80 and codepoint <= 0xA4CF and codepoint ~= 0x303F)
        or (codepoint >= 0xAC00 and codepoint <= 0xD7A3)
        or (codepoint >= 0xF900 and codepoint <= 0xFAFF)
        or (codepoint >= 0xFE10 and codepoint <= 0xFE19)
        or (codepoint >= 0xFE30 and codepoint <= 0xFE6F)
        or (codepoint >= 0xFF00 and codepoint <= 0xFF60)
        or (codepoint >= 0xFFE0 and codepoint <= 0xFFE6)
        or (codepoint >= 0x1F300 and codepoint <= 0x1FAFF)
        or (codepoint >= 0x20000 and codepoint <= 0x3FFFD)
    )
end

local function GetConsoleTextWidth(value)
    local text = tostring(value or '')
    local width = 0

    local success = pcall(function()
        for _, codepoint in utf8.codes(text) do
            if not IsZeroWidthCodepoint(codepoint) then
                width = width + (IsWideCodepoint(codepoint) and 2 or 1)
            end
        end
    end)

    return success and width or #text
end

local function PadConsoleTextRight(value, width)
    local text = tostring(value or '')
    return text..string.rep(' ', math.max(width - GetConsoleTextWidth(text), 0))
end

local function FormatVersionCheckHeader(title, leftBias)
    title = tostring(title or '')

    local padding = VERSION_CHECK_LINE_WIDTH - GetConsoleTextWidth(title) - 2
    if padding < 0 then
        return title
    end

    local leftPadding = math.floor((padding + (leftBias or 0)) / 2)
    leftPadding = math.max(0, math.min(leftPadding, padding))

    return string.rep('=', leftPadding)..' '..title..' '..string.rep('=', padding - leftPadding)
end

local function SortQueue()
    local function sortByName(a, b)
        return tostring(a.resourceName) < tostring(b.resourceName)
    end

    table.sort(VersionCheckQueue.updates, sortByName)
    table.sort(VersionCheckQueue.betas, sortByName)
    table.sort(VersionCheckQueue.errors, sortByName)
end

local function PrintVersionCheckQueue()
    if #VersionCheckQueue.updates == 0 and #VersionCheckQueue.betas == 0 and #VersionCheckQueue.errors == 0 then
        return
    end

    SortQueue()

    local lines = {}
    local line = string.rep('=', VERSION_CHECK_LINE_WIDTH)
    local header

    if #VersionCheckQueue.updates > 0 then
        header = FormatVersionCheckHeader(Locale('scripts_requiring_update'), 0)
    elseif #VersionCheckQueue.betas > 0 then
        header = FormatVersionCheckHeader(Locale('beta_test_warning'), 4)
    else
        header = FormatVersionCheckHeader(Locale('version_check_errors'), 4)
    end

    table.insert(lines, '')
    table.insert(lines, '^2'..line)
    table.insert(lines, '^2'..header..'^0')
    table.insert(lines, '^2'..line..'^0')

    if #VersionCheckQueue.updates > 0 then
        table.insert(lines, '')
        table.insert(lines, ('^3%s:^0'):format(Locale('updates_available')))

        local labels = {
            current = Locale('current')..':',
            latest = Locale('latest')..':',
            released = Locale('released')..':',
            notes = Locale('notes')..':',
            download = Locale('download')..':',
            changelog = Locale('changelog')..':'
        }

        local labelWidth = VERSION_CHECK_LABEL_MIN_WIDTH
        for _, label in pairs(labels) do
            labelWidth = math.max(labelWidth, GetConsoleTextWidth(label) + 1)
        end

        for _, update in ipairs(VersionCheckQueue.updates) do
            table.insert(lines, ('  ^5[%s]^0'):format(update.resourceName))
            table.insert(lines, ('    %s^1%s^0'):format(PadConsoleTextRight(labels.current, labelWidth), update.currentVersion))
            table.insert(lines, ('    %s^2%s^0'):format(PadConsoleTextRight(labels.latest, labelWidth), update.latestVersion))
            table.insert(lines, ('    %s^5%s^0'):format(PadConsoleTextRight(labels.released, labelWidth), update.releaseDate))
            table.insert(lines, ('    %s^5%s^0'):format(PadConsoleTextRight(labels.notes, labelWidth), update.notes))
            table.insert(lines, ('    %s^3%s^0'):format(PadConsoleTextRight(labels.download, labelWidth), update.downloadLink))
            table.insert(lines, ('    %s^3%s^0'):format(PadConsoleTextRight(labels.changelog, labelWidth), update.docsLink))
            table.insert(lines, '')
        end
    end

    if #VersionCheckQueue.betas > 0 then
        table.insert(lines, ('^3%s:^0'):format(Locale('beta_versions_detected')))

        for _, beta in ipairs(VersionCheckQueue.betas) do
            table.insert(lines, '  '..Locale('beta_running_version', ('^5[%s]^0'):format(beta.resourceName), ('^1%s^0'):format(beta.version)))
        end

        table.insert(lines, '')
        table.insert(lines, '   ^1'..Locale('beta_warning_title'))
        table.insert(lines, '   '..Locale('beta_warning_unstable'))
        table.insert(lines, '   '..Locale('beta_warning_live_servers')..'^0')
        table.insert(lines, '')
    end

    if #VersionCheckQueue.errors > 0 then
        table.insert(lines, ('^1%s:^0'):format(Locale('version_check_errors_title')))

        for _, err in ipairs(VersionCheckQueue.errors) do
            table.insert(lines, ('  ^5[%s]^0 ^1%s^0'):format(err.resourceName, err.message))
        end

        table.insert(lines, '')
    end

    table.insert(lines, '^2'..line..'^0')
    table.insert(lines, '')

    Citizen.Trace(table.concat(lines, '\n'))

    VersionCheckQueue.updates = {}
    VersionCheckQueue.betas = {}
    VersionCheckQueue.errors = {}
end

local function ScheduleVersionCheckPrint(delay)
    if versionCheckPrintScheduled then return end

    versionCheckPrintScheduled = true

    CreateThread(function()
        Wait(delay or 3000)

        versionCheckPrintScheduled = false
        PrintVersionCheckQueue()
    end)
end

local function GetSortedDependantResources()
    local resources = {}

    for resourceName in pairs(DependantResources) do
        resources[#resources + 1] = resourceName
    end

    table.sort(resources)

    return resources
end

local function CheckResourceVersion(resourceName, cb)
    if VersionCheckInProgress[resourceName] then
        if cb then cb() end
        return
    end

    VersionCheckInProgress[resourceName] = true

    local function finish()
        VersionCheckInProgress[resourceName] = nil

        if cb then
            cb()
        end
    end

    local url = githubURL[resourceName]
    local fallback_url = githubFallbackURL:format(resourceName)

    if not url or GetResourceState(resourceName) == 'missing' then
        finish()
        return
    end

    local current_version = GetResourceMetadata(resourceName, 'version', 0) or '0.0.0'
    local docs_link = docsLinks[resourceName] or 'N/A'
    local download_link = downloadLinks[resourceName] or 'N/A'

    local currentVersionData = ParseVersion(current_version)

    if not currentVersionData then
        table.insert(VersionCheckQueue.errors, {
            resourceName = resourceName,
            message = Locale('invalid_version_format', tostring(current_version))
        })

        finish()
        return
    end

    if IsBetaVersion(currentVersionData) then
        table.insert(VersionCheckQueue.betas, {
            resourceName = resourceName,
            version = currentVersionData.raw
        })
    end

    local function handleVersionResponse(statusCode, result, errorData, isFallback)
        local requestSucceeded = type(statusCode) == 'number'
            and statusCode >= 200
            and statusCode < 300
            and type(result) == 'string'
            and result ~= ''

        if not requestSucceeded then
            if not isFallback then
                PerformHttpRequest(fallback_url, function(fallbackStatusCode, fallbackResult, _, fallbackErrorData)
                    handleVersionResponse(fallbackStatusCode, fallbackResult, fallbackErrorData, true)
                end, 'GET', '', versionRequestHeaders)
                return
            end

            local errorDetails = type(errorData) == 'string'
                and errorData:gsub('[\r\n]+', ' '):match('^%s*(.-)%s*$')
                or ''

            table.insert(VersionCheckQueue.errors, {
                resourceName = resourceName,
                message = Locale(
                    'version_check_http_error',
                    tostring(statusCode or Locale('unknown')),
                    errorDetails ~= '' and errorDetails or Locale('version_check_no_response_details')
                )
            })

            finish()
            return
        end

        local success, decoded = pcall(json.decode, result)

        if not success or type(decoded) ~= 'table' then
            table.insert(VersionCheckQueue.errors, {
                resourceName = resourceName,
                message = Locale('version_check_invalid_json')
            })

            finish()
            return
        end

        local latestVersionData = ParseVersion(decoded.version)

        if not latestVersionData then
            table.insert(VersionCheckQueue.errors, {
                resourceName = resourceName,
                message = Locale('invalid_latest_version_format', tostring(decoded.version))
            })

            finish()
            return
        end

        if CompareVersions(latestVersionData, currentVersionData) then
            local formatted_current_version, formatted_new_version = FormatVersion(currentVersionData, latestVersionData)

            table.insert(VersionCheckQueue.updates, {
                resourceName = resourceName,
                currentVersion = formatted_current_version,
                latestVersion = formatted_new_version,
                releaseDate = FormatReleaseDate(decoded.release_date),
                notes = decoded.notes or Locale('no_notes_provided'),
                downloadLink = download_link,
                docsLink = docs_link
            })
        end

        finish()
    end

    PerformHttpRequest(url, function(statusCode, result, _, errorData)
        handleVersionResponse(statusCode, result, errorData, false)
    end, 'GET', '', versionRequestHeaders)
end

CreateThread(function()
    Wait(5000)

    local resources = GetSortedDependantResources()
    local pending = 0

    for _, resourceName in ipairs(resources) do
        if githubURL[resourceName] and GetResourceState(resourceName) ~= 'missing' then
            pending = pending + 1
        end
    end

    if pending == 0 then
        InitialVersionCheckRunning = false
        return
    end

    local function done()
        pending = pending - 1

        if pending <= 0 then
            PrintVersionCheckQueue()
            InitialVersionCheckRunning = false
        end
    end

    for _, resourceName in ipairs(resources) do
        if githubURL[resourceName] and GetResourceState(resourceName) ~= 'missing' then
            CheckResourceVersion(resourceName, done)
        end
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if InitialVersionCheckRunning then return end
    if resourceName == GetCurrentResourceName() then return end
    if not DependantResources[resourceName] then return end
    if not githubURL[resourceName] then return end

    CreateThread(function()
        Wait(1000)

        CheckResourceVersion(resourceName, function()
            ScheduleVersionCheckPrint(3000)
        end)
    end)
end)
