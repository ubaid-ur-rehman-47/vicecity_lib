--[[
    Vehicle persistence layer (server) — normalized vehicle record operations.
    Provider-owned by default (the resolved garage adapter's own vehicle
    table); falls back to a configured SQL mapping only when
    `ViceCityConfig.vehicles.sqlFallback` is set explicitly, using
    parameterized queries against the declared table/columns only.
]]

local function sqlConfig()
    return (ViceCityConfig.vehicles or {}).sqlFallback
end

local function garageAdapter()
    return ViceCity.GarageAdapter
end

ViceCity.Vehicles = ViceCity.Vehicles or {}

function ViceCity.Vehicles.List(garageId, owner)
    local adapter = garageAdapter()
    if adapter and adapter.listVehicles then
        local ok, result = adapter:listVehicles(garageId, owner)
        if ok ~= false then return ok, result end
    end
    return ViceCity.Vehicles.SqlList(garageId, owner)
end

function ViceCity.Vehicles.SqlList(garageId, owner)
    local cfg = sqlConfig()
    if not cfg or not cfg.table or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('list')
    end
    local where, params = {}, {}
    if garageId and cfg.garageColumn then
        where[#where + 1] = cfg.garageColumn .. ' = ?'
        params[#params + 1] = garageId
    end
    if owner and cfg.identifierColumn then
        where[#where + 1] = cfg.identifierColumn .. ' = ?'
        params[#params + 1] = owner
    end
    local clause = #where > 0 and (' WHERE ' .. table.concat(where, ' AND ')) or ''
    return ViceCity.Database.Query(('SELECT * FROM %s%s'):format(cfg.table, clause), params)
end

function ViceCity.Vehicles.GetByPlate(plate)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not cfg or not cfg.table or not cfg.plateColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('getByPlate')
    end
    local rows = ViceCity.Database.Query(
        ('SELECT * FROM %s WHERE %s = ? LIMIT 1'):format(cfg.table, cfg.plateColumn), { plate })
    if type(rows) == 'table' and rows[1] then return rows[1] end
    return false, { reason = 'not_found', plate = plate }
end

function ViceCity.Vehicles.IsOwnedBy(plate, identifier)
    local record = ViceCity.Vehicles.GetByPlate(plate)
    local cfg = sqlConfig()
    if not record or not cfg then return false end
    return record[cfg.identifierColumn] == identifier
end

function ViceCity.Vehicles.SetGarage(plate, garageId, status)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not cfg or not cfg.table or not cfg.plateColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('setGarage')
    end
    local sets, params = {}, {}
    if cfg.garageColumn then
        sets[#sets + 1] = cfg.garageColumn .. ' = ?'
        params[#params + 1] = garageId
    end
    if cfg.stateColumn then
        sets[#sets + 1] = cfg.stateColumn .. ' = ?'
        params[#params + 1] = status
    end
    if #sets == 0 then return false, ViceCity.VehiclesUnsupportedResult('setGarage') end
    params[#params + 1] = plate
    return ViceCity.Database.Execute(
        ('UPDATE %s SET %s WHERE %s = ?'):format(cfg.table, table.concat(sets, ', '), cfg.plateColumn), params)
end
