DB = {}
local which = (Cfg and Cfg.Database)

local function _encodeParams(sql, params)
    if not params or not next(params) then
        return '    {}'
    end

    local lines = {}
    local added = {}

    local function addParam(key)
        if added[key] or params[key] == nil then return end

        local value = params[key]
        local ok, encoded = pcall(json.encode, value)

        lines[#lines + 1] = ('    %s = %s'):format(
            tostring(key),
            ok and encoded or tostring(value)
        )

        added[key] = true
    end

    for key in tostring(sql or ''):gmatch('@[%w_]+') do
        addParam(key)
    end

    for key in pairs(params) do
        addParam(key)
    end

    return table.concat(lines, '\n')
end

local function _cleanSQL(sql)
    sql = tostring(sql or '')
    sql = sql:gsub('\r\n', ' ')
    sql = sql:gsub('\n', ' ')
    sql = sql:gsub('\t', ' ')
    sql = sql:gsub('%s+', ' ')
    sql = sql:gsub('^%s+', '')
    sql = sql:gsub('%s+$', '')

    sql = sql:gsub('%s+FROM%s+', '\n    FROM ')
    sql = sql:gsub('%s+WHERE%s+', '\n    WHERE ')
    sql = sql:gsub('%s+AND%s+', '\n        AND ')
    sql = sql:gsub('%s+OR%s+', '\n        OR ')
    sql = sql:gsub('%s+GROUP BY%s+', '\n    GROUP BY ')
    sql = sql:gsub('%s+ORDER BY%s+', '\n    ORDER BY ')
    sql = sql:gsub('%s+LIMIT%s+', '\n    LIMIT ')
    sql = sql:gsub('%s+VALUES%s+', '\n    VALUES ')
    sql = sql:gsub('%s+SET%s+', '\n    SET ')

    return '    '..sql
end

local function _resultSummary(res)
    if type(res) == 'table' then
        return ('rows: %s'):format(#res)
    end

    if type(res) == 'number' then
        return ('affected: %s'):format(res)
    end

    if res == nil then
        return 'nil'
    end

    return tostring(res)
end

local function _printDBDebug(label, sql, params, ms, ok, res)
    Citizen.Trace(([[^5================================================================
^3[DB]^0 %-6s ^5|^0 %-12s ^5|^0 %sms ^5|^0 %s
^5----------------------------------------------------------------
^3SQL^0
%s
^3PARAMS^0
%s
^3RESULT^0 %s
^5================================================================^0
]]):format(
        tostring(label):upper(),
        tostring(which),
        tostring(ms),
        ok and '^2OK^0' or '^1ERROR^0',
        _cleanSQL(sql),
        _encodeParams(sql, params),
        ok and _resultSummary(res) or tostring(res)
    ))
end

local function _timed(label, sql, params, fn)
    local t0 = GetGameTimer()
    local ok, res = pcall(fn)
    local dt = GetGameTimer() - t0

    if Cfg.BridgeDebugSQL or not ok then
        _printDBDebug(label, sql, params, dt, ok, res)
    end

    if not ok then
        return nil, res
    end

    return res, nil
end

local function _dbValue(row, ...)
    if not row then return nil end

    for _, key in ipairs({...}) do
        if row[key] ~= nil then
            return row[key]
        end
    end

    return nil
end

function DB.fetch(sql, params)
    params = params or {}

    if which == 'oxmysql' then
        return _timed('fetch', sql, params, function()
            local p = promise.new()

            exports.oxmysql:fetch(sql, params, function(rows)
                p:resolve(rows or {})
            end)

            return Citizen.Await(p)
        end)

    elseif which == 'mysql-async' then
        return _timed('fetch', sql, params, function()
            local p = promise.new()

            MySQL.Async.fetchAll(sql, params, function(rows)
                p:resolve(rows)
            end)

            return Citizen.Await(p)
        end)

    elseif which == 'ghmattimysql' then
        return _timed('fetch', sql, params, function()
            local p = promise.new()

            exports['ghmattimysql']:execute(sql, params, function(rows)
                p:resolve(rows)
            end)

            return Citizen.Await(p)
        end)
    end
end

function DB.exec(sql, params)
    params = params or {}

    if which == 'oxmysql' then
        return _timed('exec', sql, params, function()
            local p = promise.new()

            exports.oxmysql:execute(sql, params, function(affected)
                p:resolve(affected or 0)
            end)

            return Citizen.Await(p)
        end)

    elseif which == 'mysql-async' then
        return _timed('exec', sql, params, function()
            local p = promise.new()

            MySQL.Async.execute(sql, params, function(affected)
                p:resolve(affected or 0)
            end)

            return Citizen.Await(p)
        end)

    elseif which == 'ghmattimysql' then
        return _timed('exec', sql, params, function()
            local p = promise.new()

            exports['ghmattimysql']:execute(sql, params, function(affected)
                p:resolve(affected or 0)
            end)

            return Citizen.Await(p)
        end)
    end
end

function DB.executeAsync(sql, params)
    params = params or {}

    local t0 = GetGameTimer()

    local function done(result)
        if Cfg.BridgeDebugSQL then
            _printDBDebug('async', sql, params, GetGameTimer() - t0, true, result)
        end
    end

    if which == 'oxmysql' then
        exports.oxmysql:execute(sql, params, function(affected)
            done(affected or 0)
        end)

    elseif which == 'mysql-async' then
        MySQL.Async.execute(sql, params, function(affected)
            done(affected or 0)
        end)

    elseif which == 'ghmattimysql' then
        exports['ghmattimysql']:execute(sql, params, function(affected)
            done(affected or 0)
        end)
    end
end

function DB.insert(sql, params)
    params = params or {}

    if which == 'oxmysql' then
        return _timed('insert', sql, params, function()
            local p = promise.new()

            exports.oxmysql:insert(sql, params, function(insertId)
                p:resolve(insertId)
            end)

            return Citizen.Await(p)
        end)

    elseif which == 'mysql-async' then
        return _timed('insert', sql, params, function()
            local p = promise.new()

            MySQL.Async.insert(sql, params, function(insertId)
                p:resolve(insertId)
            end)

            return Citizen.Await(p)
        end)

    elseif which == 'ghmattimysql' then
        local affected = DB.exec(sql, params)

        if affected then
            return tonumber(DB.scalar('SELECT LAST_INSERT_ID()'))
        end
    end
end

function DB.scalar(sql, params)
    local rows = DB.fetch(sql, params)

    if rows and rows[1] then
        for _, v in pairs(rows[1]) do
            return v
        end
    end

    return nil
end

function DB.single(sql, params)
    local rows = DB.fetch(sql, params)
    return (rows and rows[1]) or nil
end

function DB.count(sql, params)
    local val = DB.scalar(sql, params)
    return tonumber(val) or 0
end

function DB.exists(sql, params)
    local val = DB.scalar(sql, params)
    return val ~= nil
end

function DB.tableExists(tableName)
    local sql = [[
        SELECT 1 FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = ? LIMIT 1
    ]]

    return DB.scalar(sql, {tableName}) ~= nil
end

function DB.columnExists(tableName, columnName)
    local sql = [[
        SELECT 1 FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ? LIMIT 1
    ]]

    return DB.scalar(sql, {tableName, columnName}) ~= nil
end

function DB.columnInfo(tableName, columnName)
    local sql = [[
        SELECT COLUMN_TYPE AS column_type, DATA_TYPE AS data_type, IS_NULLABLE AS is_nullable, COLUMN_DEFAULT AS column_default
        FROM information_schema.columns
        WHERE table_schema = DATABASE() AND table_name = ? AND column_name = ? LIMIT 1
    ]]

    return DB.single(sql, {tableName, columnName})
end

function DB.columnMatches(tableName, columnName, checks)
    local column = DB.columnInfo(tableName, columnName)
    if not column then return false, nil end

    checks = checks or {}

    local columnType = tostring(_dbValue(column, 'column_type', 'COLUMN_TYPE') or ''):lower()
    local dataType = tostring(_dbValue(column, 'data_type', 'DATA_TYPE') or ''):lower()
    local nullable = tostring(_dbValue(column, 'is_nullable', 'IS_NULLABLE') or ''):upper() == 'YES'
    local default = _dbValue(column, 'column_default', 'COLUMN_DEFAULT')

    if checks.column_type then
        local valid = false

        if type(checks.column_type) == 'table' then
            for _, expectedType in ipairs(checks.column_type) do
                if columnType == tostring(expectedType):lower() then
                    valid = true
                    break
                end
            end
        else
            valid = columnType == tostring(checks.column_type):lower()
        end

        if not valid then
            return false, column
        end
    end

    if checks.data_type then
        local valid = false

        if type(checks.data_type) == 'table' then
            for _, expectedType in ipairs(checks.data_type) do
                if dataType == tostring(expectedType):lower() then
                    valid = true
                    break
                end
            end
        else
            valid = dataType == tostring(checks.data_type):lower()
        end

        if not valid then
            return false, column
        end
    end

    if checks.nullable ~= nil and nullable ~= checks.nullable then
        return false, column
    end

    if checks.default_is_null == true then
        if default ~= nil and tostring(default):upper() ~= 'NULL' then
            return false, column
        end

    elseif checks.default ~= nil then
        if tostring(default) ~= tostring(checks.default) then
            return false, column
        end
    end

    return true, column
end

function DB.columnNeedsChange(tableName, columnName, checks)
    local matches, column = DB.columnMatches(tableName, columnName, checks)

    if not column then
        return false
    end

    return not matches
end

function DB.hasEmptyString(tableName, columnName)
    return DB.count(('SELECT COUNT(*) FROM %s WHERE %s = ?;'):format(tableName, columnName), {''}) > 0
end

return DB