-- Rounds numbers to a specified number of decimal places.
function RoundDecimals(data, decimalPlaces)
    decimalPlaces = decimalPlaces or 2
    local mult = 10 ^ decimalPlaces

    local function r(n)
        return Round(n * mult) / mult
    end

    if type(data) == 'vector4' then
        return {x = r(data.x), y = r(data.y), z = r(data.z), h = r(data.w)}

    elseif type(data) == 'vector3' then
        return {x = r(data.x), y = r(data.y), z = r(data.z)}

    elseif type(data) == 'number' then
        return r(data)

    elseif type(data) == 'table' then
        for k, v in pairs(data) do
            if type(v) == 'number' then
                data[k] = r(v)
            end
        end
        return data
    end
end

-- Rounds a number to the nearest integer.
function Round(num)
    return num >= 0 and math.floor(num + 0.5) or math.ceil(num - 0.5)
end

-- Trims whitespace from both ends of a string.
function Trim(str)
    return str:match("^%s*(.-)%s*$")
end

-- Capitalizes the first letter of a string.
function CapitalizeFirstLetter(str)
    return (str:gsub("^%l", string.upper))
end

-- Capitalizes the first letter of each word in a string.
function CapitalizeWords(str)
    if type(str) ~= 'string' then return str end
    return (str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end))
end

-- Checks if a string is nil, not a string, or consists only of whitespace.
function IsBlankString(str)
    return type(str) ~= 'string' or str:match('^%s*$') ~= nil
end

-- Normalizes the case of a string to either upper or lower case.
function FormatTextCase(string, mode)
    if type(string) ~= 'string' then
        return string
    end

    mode = mode and string.lower(mode) or 'upper'

    if mode == 'lower' then
        return string.lower(string)
    end

    return string.upper(string)
end

-- Generates a unique identifier string.
local __uid_counter = 0
function GenerateUniqueId(length)
    length = length or 16
    __uid_counter = __uid_counter + 1

    local ALPH = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    local parts = {}

    local blocks = math.ceil(length / 6)

    for _ = 1, blocks do
        local t = GetGameTimer()
        local salt = string.format(
            '%d:%d:%d:%d:%d:%d',
            t * math.random(17, 97),
            t + math.random(0, 0x7FFFFFFF),
            __uid_counter * math.random(3, 29),
            math.random(0, 0x7FFFFFFF),
            math.random(0, 0x7FFFFFFF),
            (t % 1000) * math.random(1, 1000)
        )

        local h = 2166136261
        for i = 1, #salt do
            h = (h ~ salt:byte(i)) & 0xFFFFFFFF
            h = (h * 16777619) % 0x100000000
        end

        local block = {}
        for i = 1, 6 do
            local idx = (h % #ALPH) + 1
            block[i] = ALPH:sub(idx, idx)
            h = math.floor(h / #ALPH)
        end

        parts[#parts + 1] = table.concat(block)
    end

    local raw = table.concat(parts):sub(1, length)

    local t = {}
    for i = 1, #raw do
        t[i] = raw:sub(i, i)
    end
    for i = #t, 2, -1 do
        local j = math.random(1, i)
        t[i], t[j] = t[j], t[i]
    end
    raw = table.concat(t)

    local out = {}
    for i = 1, length do
        out[#out + 1] = raw:sub(i, i)
        if i % 4 == 0 and i < length then
            out[#out + 1] = '-'
        end
    end

    return table.concat(out)
end

-- Registers a legacy export for a resource.
function RegisterLegacyExport(resourceName, exportName, callback)
    if not TypeCheck(resourceName, 'string', '4993', '"resourceName" must be a string.') then
        return
    end

    if not TypeCheck(exportName, 'string', '4994', '"exportName" must be a string.') then
        return
    end

    if not TypeCheck(callback, 'function', '4995', '"callback" must be a function.') then
        return
    end

    if resourceName == '' or exportName == '' then
        ERROR('4996', 'resourceName and exportName cannot be empty strings.')
        return
    end

    AddEventHandler(('__cfx_export_%s_%s'):format(resourceName, exportName), function(register)
        register(function(...)
            local ok, result = pcall(callback, ...)
            if ok then
                return result
            end
            ERROR('4997', ('[RegisterLegacyExport] %s:%s failed: %s'):format(resourceName, exportName, tostring(result)))
            return nil
        end)
    end)
end

-- Gets the network ID of an entity.
function GetNetId(entity)
    if DoesEntityExist(entity) then
        return NetworkGetNetworkIdFromEntity(entity)
    else
        WARN('7255', 'Attempted to get network ID of invalid entity')
        return nil
    end
end

-- Gets the entity ID from a network ID, returns nil if it doesn't exist.
function GetEntityIdFromNetId(netId)
    if not netId then
        WARN('7254', 'Attempted to get entity from nil network ID')
        return nil
    end

    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        return entity
    else
        WARN('7256', 'Attempted to get entity from invalid network ID')
        return nil
    end
end

-- Waits for an entity to exist from a netId, returns nil if it doesn't exist after the timeout.
function WaitForEntityFromNetId(netId, timeout)
    if not netId then
        if Cfg.BridgeDebug then
            WARN('7258', 'Attempted to get entity from nil network ID')
        end
        return nil
    end

    timeout = timeout or 5000
    local attempts = math.floor(timeout / 100)
    local entity = NetworkGetEntityFromNetworkId(netId)

    local i = 0
    while entity == 0 and i < attempts do
        Wait(100)
        entity = NetworkGetEntityFromNetworkId(netId)
        i = i + 1
    end

    if entity == 0 or not DoesEntityExist(entity) then
        if Cfg.BridgeDebug then
            WARN('4356', 'Entity does not exist after waiting.')
        end
        return nil
    end
    return entity
end

-- Waits for a network ID to exist from an entity, returns nil if it doesn't exist after the timeout.
function WaitForNetworkIdFromEntity(vehicle, timeout)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then
        if Cfg.BridgeDebug then
            WARN('7259', 'Attempted to get network ID from invalid entity')
        end
        return nil
    end

    timeout = timeout or 5000
    local attempts = math.floor(timeout / 100)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)

    local i = 0
    while netId == 0 and i < attempts do
        Wait(100)
        netId = NetworkGetNetworkIdFromEntity(vehicle)
        i = i + 1
    end

    if netId == 0 then WARN('4357', 'Network ID does not exist after waiting.') return nil end
    return netId
end

-- Returns true if the current resource is cd_bridge, false otherwise.
function IsBridgeResource()
    return GetCurrentResourceName() == 'cd_bridge'
end

-- Creates a deep copy of a table using JSON encoding and decoding.
function DeepCopy(data)
    return json.decode(json.encode(data))
end

-- Gets the key label for a key press event.
function GetKeyPressKeyLabel(key)
    for k, v in pairs(Cfg.Keys) do
        if v == key then
            return k
        end
    end
    return '?'
end

-- Checks if the bridge has finished loading.
function HasBridgeLoaded()
    return BridgeLoaded
end

-- Waits for the bridge to finish loading, showing warnings if it takes too long.
function WaitForBridgeToLoad()
    if BridgeLoaded then return true end

    local bridgeLoadStartTime = GetGameTimer()
    local nextBridgeWarning = 10000
    local bridgeLoadWarningShown = false

    while not BridgeLoaded do
        Wait(0)

        local elapsed = GetGameTimer() - bridgeLoadStartTime

        if elapsed >= nextBridgeWarning then
            WARN('0001', 'The bridge is still loading. Elapsed loading time: '..math.floor(elapsed / 1000)..' seconds')
            bridgeLoadWarningShown = true
            nextBridgeWarning = nextBridgeWarning + 10000
        end
    end

    if bridgeLoadWarningShown then
        local totalElapsed = GetGameTimer() - bridgeLoadStartTime
        AUTOFIX('The bridge has finished loading. Total loading time: '..math.floor(totalElapsed / 1000)..' seconds')
    end

    return true
end