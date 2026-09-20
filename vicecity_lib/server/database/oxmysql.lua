--[[
    oxmysql database adapter — parameterized query/execute/insert via
    oxmysql's async API, awaited synchronously for simple call sites.
]]

local provider = {
    name = 'oxmysql',
    resource = 'oxmysql',
    capabilities = { query = true, execute = true, insert = true },
}

function provider:query(query, params)
    local ok, result = pcall(function() return exports.oxmysql:query_async(query, params or {}) end)
    if not ok then return false, tostring(result) end
    return result or {}
end

function provider:execute(query, params)
    local ok, result = pcall(function() return exports.oxmysql:execute_async(query, params or {}) end)
    if not ok then return false, tostring(result) end
    return result
end

function provider:insert(query, params)
    local ok, result = pcall(function() return exports.oxmysql:insert_async(query, params or {}) end)
    if not ok then return false, tostring(result) end
    return result
end

ViceCity.RegisterProvider('database', 'oxmysql', provider)
