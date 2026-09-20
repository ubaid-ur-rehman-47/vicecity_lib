--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not CBUX then
    CBUX = {}
end

CBUX.Utils = {}

function CBUX.Utils.Debug(...)
    if Config.Debug then
        local args = {...}
        local msg = "[CBUX Bridge] "
        for _, arg in ipairs(args) do
            msg = msg .. tostring(arg) .. " "
        end
        print(msg)
    end
end

function CBUX.Utils.Print(...)
    local args = {...}
    local msg = "[CBUX Bridge] "
    for _, arg in ipairs(args) do
        msg = msg .. tostring(arg) .. " "
    end
    print(msg)
end

function CBUX.Utils.Error(...)
    local args = {...}
    local msg = "^1[CBUX Bridge ERROR] "
    for _, arg in ipairs(args) do
        msg = msg .. tostring(arg) .. " "
    end
    print(msg .. "^0")
end

function CBUX.Utils.Warn(...)
    local args = {...}
    local msg = "^3[CBUX Bridge WARN] "
    for _, arg in ipairs(args) do
        msg = msg .. tostring(arg) .. " "
    end
    print(msg .. "^0")
end

function CBUX.Utils.IsResourceStarted(resourceName)
    return GetResourceState(resourceName) == "started"
end

function CBUX.Utils.DeepCopy(obj)
    if type(obj) == "table" then
        local copy = {}
        for k, v in next, obj, nil do
            copy[CBUX.Utils.DeepCopy(k)] = CBUX.Utils.DeepCopy(v)
        end
        setmetatable(copy, CBUX.Utils.DeepCopy(getmetatable(obj)))
        return copy
    end
    return obj
end

function CBUX.Utils.MergeTables(t1, t2)
    local result = CBUX.Utils.DeepCopy(t1)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(result[k]) == "table" then
            result[k] = CBUX.Utils.MergeTables(result[k], v)
        else
            result[k] = v
        end
    end
    return result
end

function CBUX.Utils.TableContains(t, val)
    for _, v in pairs(t) do
        if v == val then
            return true
        end
    end
    return false
end

function CBUX.Utils.TableLength(t)
    local count = 0
    for _ in pairs(t) do
        count = count + 1
    end
    return count
end

function CBUX.Utils.ToNumber(val, default)
    local num = tonumber(val)
    if num then
        return num
    end
    return default or 0
end

function CBUX.Utils.ToString(val, default)
    if val == nil then
        return default or ""
    end
    return tostring(val)
end

function CBUX.Utils.Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function CBUX.Utils.Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

local idCounter = 0
function CBUX.Utils.GenerateId()
    idCounter = idCounter + 1
    return string.format("%s_%d_%d", GetCurrentResourceName(), GetGameTimer(), idCounter)
end

function CBUX.Utils.StartsWith(str, startStr)
    return string.sub(str, 1, string.len(startStr)) == startStr
end

function CBUX.Utils.EndsWith(str, endStr)
    return endStr == "" or string.sub(str, -string.len(endStr)) == endStr
end

function CBUX.Utils.Split(str, sep)
    local result = {}
    local pattern = string.format("([^%s]+)", sep)
    for match in string.gmatch(str, pattern) do
        result[#result + 1] = match
    end
    return result
end

function CBUX.Utils.Trim(str)
    return string.match(str, "^%s*(.-)%s*$")
end

function CBUX.Utils.FormatMoney(amount)
    local formatted = tostring(math.floor(amount))
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if k == 0 then
            break
        end
    end
    return "$" .. formatted
end

function CBUX.Utils.CreatePromise()
    local promise = {
        resolved = false,
        value = nil,
        callbacks = {}
    }
    
    function promise.resolve(self, val)
        if self.resolved then return end
        self.resolved = true
        self.value = val
        for _, cb in ipairs(self.callbacks) do
            cb(val)
        end
    end
    
    function promise.next(self, cb)
        if self.resolved then
            cb(self.value)
        else
            table.insert(self.callbacks, cb)
        end
        return self
    end
    
    function promise.await(self, timeout)
        timeout = timeout or 10000
        local startTime = GetGameTimer()
        while not self.resolved do
            Wait(0)
            if (GetGameTimer() - startTime) > timeout then
                CBUX.Utils.Error("Promise timeout after", timeout, "ms")
                return nil
            end
        end
        return self.value
    end
    
    return promise
end

function CBUX.Utils.ValidateIdentifier(identifier)
    if type(identifier) ~= "string" then return false end
    
    if string.match(identifier, "^steam:") then return true end
    if string.match(identifier, "^license:") then return true end
    if string.match(identifier, "^license2:") then return true end
    if string.match(identifier, "^discord:") then return true end
    if string.match(identifier, "^fivem:") then return true end
    if string.match(identifier, "^ip:") then return true end
    
    if string.match(identifier, "^[A-Z0-9]+$") then
        if #identifier >= 6 then return true end
    end
    
    return false
end

function CBUX.Utils.VectorToTable(vec)
    if type(vec) == "vector4" then
        return {x = vec.x, y = vec.y, z = vec.z, w = vec.w}
    elseif type(vec) == "vector3" then
        return {x = vec.x, y = vec.y, z = vec.z}
    elseif type(vec) == "table" then
        return vec
    end
    return nil
end

function CBUX.Utils.TableToVector(tbl)
    if not tbl then return nil end
    if tbl.w then
        return vector4(tbl.x or 0, tbl.y or 0, tbl.z or 0, tbl.w or 0)
    else
        return vector3(tbl.x or 0, tbl.y or 0, tbl.z or 0)
    end
end

function CBUX.Utils.JsonEncode(tbl)
    local success, result = pcall(json.encode, tbl)
    if success then return result end
    CBUX.Utils.Error("JSON encode failed:", result)
    return nil
end

function CBUX.Utils.JsonDecode(str)
    if not str or str == "" then return nil end
    local success, result = pcall(json.decode, str)
    if success then return result end
    CBUX.Utils.Error("JSON decode failed:", result)
    return nil
end

function CBUX.Utils.EnsureNumber(val, min, max, default)
    local num = tonumber(val)
    if not num then return default or min or 0 end
    if min and min > num then return min end
    if max and max < num then return max end
    return num
end

function CBUX.Utils.OnceEvent(eventName, cb)
    local handler = nil
    handler = AddEventHandler(eventName, function(...)
        RemoveEventHandler(handler)
        cb(...)
    end)
    return handler
end

function CBUX.Utils.Retry(func, maxAttempts, delayMs)
    maxAttempts = maxAttempts or 3
    delayMs = delayMs or 1000
    
    for i = 1, maxAttempts do
        local success, result = pcall(func)
        if success then return true, result end
        if i < maxAttempts then
            CBUX.Utils.Warn("Attempt", i, "failed, retrying in", delayMs, "ms...")
            Wait(delayMs)
        end
    end
    return false, nil
end