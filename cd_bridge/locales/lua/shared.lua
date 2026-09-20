BridgeLocalesTable = BridgeLocalesTable or {}

local resourceName = 'cd_bridge'

local function loadLocaleFile(localeKey)
    local path = ('locales/lua/%s.lua'):format(localeKey)
    local content = LoadResourceFile(resourceName, path)
    if not content then
        return false, ('Failed to load locale file: %s/%s'):format(resourceName, path)
    end

    local fn, err = load(content, ('@%s/%s'):format(resourceName, path))
    if not fn then
        return false, ('Failed to compile locale file: %s/%s - %s'):format(resourceName, path, tostring(err))
    end

    local ok, runtimeErr = pcall(fn)
    if not ok then
        BridgeLocalesTable[localeKey] = nil
        return false, ('Failed to run locale file: %s/%s - %s'):format(resourceName, path, tostring(runtimeErr))
    end

    if type(BridgeLocalesTable[localeKey]) ~= 'table' then
        BridgeLocalesTable[localeKey] = nil
        return false, ('Locale file %s/%s did not create BridgeLocalesTable[%s]'):format(resourceName, path, localeKey)
    end

    return true
end

function LoadBridgeLocaleFile(localeKey)
    localeKey = tostring(localeKey or 'EN'):upper()

    if type(BridgeLocalesTable[localeKey]) == 'table' then
        return BridgeLocalesTable
    end

    local loaded, message = loadLocaleFile(localeKey)
    if loaded then
        return BridgeLocalesTable
    end

    if localeKey == 'EN' then
        WaitForErrorHandlingToLoad()
        ERROR('3430', message .. ' Locale fallback unavailable.')
        return BridgeLocalesTable
    end

    if type(BridgeLocalesTable['EN']) ~= 'table' then
        local loadedEN, enMessage = loadLocaleFile('EN')
        if not loadedEN then
            WaitForErrorHandlingToLoad()
            ERROR('3431', message .. ' Locale fallback unavailable: ' .. enMessage)
            return BridgeLocalesTable
        end
    end

    BridgeLocalesTable[localeKey] = BridgeLocalesTable['EN']
    WaitForErrorHandlingToLoad()
    AUTOFIX(message .. ' Using EN locale instead.')
    return BridgeLocalesTable
end
LoadBridgeLocaleFile(Cfg.Language)

function Locale(locale_key, ...)
    if not locale_key then
        WaitForErrorHandlingToLoad()
        ERROR('0080', 'Locale key is nil')
        return ''
    end

    local preferred = tostring(Cfg.Language):upper()

    local function getFromOneTable(tbl, langKey)
        if not tbl then return nil end
        if tbl[langKey] and tbl[langKey][locale_key] then
            return tbl[langKey][locale_key]
        end
        return nil
    end

    local function findMessage(langKey)
        return getFromOneTable(LocalesTable, langKey) or getFromOneTable(Locales, langKey) or getFromOneTable(BridgeLocalesTable, langKey)
    end

    local message = findMessage(preferred)
    if not message and preferred ~= 'EN' then
        message = findMessage('EN')
    end

    if not message then
        WaitForErrorHandlingToLoad()
        WARN('0081', 'Locale not found: [' .. tostring(locale_key) .. '] (lang tried: ' .. preferred .. ' -> EN)')
        return tostring(locale_key)
    end

    if select('#', ...) == 0 then
        return message
    end

    local ok, formatted = pcall(string.format, message, ...)
    if ok then
        return formatted
    end

    WaitForErrorHandlingToLoad()
    ERROR('0082', ('String format failed for locale key: %s | Args: %s'):format(tostring(locale_key), json.encode({ ... })))
    return message
end