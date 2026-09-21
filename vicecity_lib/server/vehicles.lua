--[[
    Vehicle persistence layer (server) — normalized vehicle CRUD operations.
    Provider-owned by default (the resolved garage adapter's own vehicle
    table); falls back to a configured SQL mapping only when
    `ViceCityConfig.vehicles.sqlFallback` is set explicitly, using
    parameterized queries against the declared table/columns only.
]]

---@class ViceCityVehicleSqlFallback
---@field table string
---@field plateColumn string
---@field identifierColumn string?
---@field modelColumn string?
---@field garageColumn string?
---@field stateColumn string?
---@field propsColumn string?
---@field engineColumn string?
---@field bodyColumn string?
---@field fuelColumn string?

---@return ViceCityVehicleSqlFallback?
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
    local rows = ViceCity.Database.Query(('SELECT * FROM %s%s'):format(cfg.table, clause), params)
    if type(rows) ~= 'table' then return false, { reason = 'provider_error', operation = 'list' } end
    return true, rows
end

function ViceCity.Vehicles.ListOwned(owner)
    if not owner then return false, { reason = 'invalid_owner', operation = 'listOwned' } end
    return ViceCity.Vehicles.List(nil, owner)
end

function ViceCity.Vehicles.Counts(owner)
    local ok, rows = ViceCity.Vehicles.ListOwned(owner)
    if not ok or type(rows) ~= 'table' then return 0 end
    return #rows
end

function ViceCity.Vehicles.Get(plate)
    return ViceCity.Vehicles.GetByPlate(plate)
end

function ViceCity.Vehicles.GetByPlate(plate)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('getByPlate')
    end
    local rows = ViceCity.Database.Query(
        ('SELECT * FROM %s WHERE %s = ? LIMIT 1'):format(cfg.table, cfg.plateColumn), { plate })
    if type(rows) == 'table' and rows[1] then return true, rows[1] end
    return false, { reason = 'not_found', plate = plate }
end

function ViceCity.Vehicles.IsOwnedBy(plate, identifier)
    local cfg = sqlConfig()
    local ok, record = ViceCity.Vehicles.GetByPlate(plate)
    if not ok or not cfg or not cfg.identifierColumn then return false end
    return record[cfg.identifierColumn] == identifier
end

-- Create requires the caller to already own a vehicle model list/price check;
-- this only inserts the normalized ownership row.
function ViceCity.Vehicles.Create(plate, model, owner, garage, props)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not cfg.modelColumn
        or not cfg.identifierColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('create')
    end
    local columns = { cfg.plateColumn, cfg.modelColumn, cfg.identifierColumn }
    local values = { plate, model, owner }
    if cfg.garageColumn then
        columns[#columns + 1] = cfg.garageColumn
        values[#values + 1] = garage
    end
    if cfg.propsColumn then
        columns[#columns + 1] = cfg.propsColumn
        values[#values + 1] = props and json.encode(props) or nil
    end
    local placeholders = {}
    for i = 1, #columns do placeholders[i] = '?' end
    local query = ('INSERT INTO %s (%s) VALUES (%s)'):format(cfg.table, table.concat(columns, ', '),
        table.concat(placeholders, ', '))
    local result, err = ViceCity.Database.Insert(query, values)
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:created', plate, owner, garage)
    return true, plate
end

function ViceCity.Vehicles.Delete(plate)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('delete')
    end
    local result, err = ViceCity.Database.Execute(
        ('DELETE FROM %s WHERE %s = ?'):format(cfg.table, cfg.plateColumn), { plate })
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:deleted', plate)
    return true, result
end

function ViceCity.Vehicles.SetOwner(plate, identifier)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not cfg.identifierColumn
        or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('setOwner')
    end
    local result, err = ViceCity.Database.Execute(
        ('UPDATE %s SET %s = ? WHERE %s = ?'):format(cfg.table, cfg.identifierColumn, cfg.plateColumn),
        { identifier, plate })
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:updated', plate, 'owner', identifier)
    return true, result
end

function ViceCity.Vehicles.SetGarage(plate, garageId)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not cfg.garageColumn
        or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('setGarage')
    end
    local result, err = ViceCity.Database.Execute(
        ('UPDATE %s SET %s = ? WHERE %s = ?'):format(cfg.table, cfg.garageColumn, cfg.plateColumn),
        { garageId, plate })
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:updated', plate, 'garage', garageId)
    return true, result
end

function ViceCity.Vehicles.SetState(plate, status)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not cfg.stateColumn
        or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('setState')
    end
    local result, err = ViceCity.Database.Execute(
        ('UPDATE %s SET %s = ? WHERE %s = ?'):format(cfg.table, cfg.stateColumn, cfg.plateColumn),
        { status, plate })
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:updated', plate, 'state', status)
    return true, result
end

function ViceCity.Vehicles.SaveProperties(plate, props)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or type(props) ~= 'table' or not cfg or not cfg.table or not cfg.plateColumn
        or not cfg.propsColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('saveProperties')
    end
    local result, err = ViceCity.Database.Execute(
        ('UPDATE %s SET %s = ? WHERE %s = ?'):format(cfg.table, cfg.propsColumn, cfg.plateColumn),
        { json.encode(props), plate })
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:updated', plate, 'properties')
    return true, result
end

-- Resets engine/body/fuel to full only for the columns this schema declares.
function ViceCity.Vehicles.Repair(plate)
    local cfg = sqlConfig()
    plate = ViceCity.VehiclesNormalizePlate(plate)
    if not plate or not cfg or not cfg.table or not cfg.plateColumn or not ViceCity.Database.IsAvailable() then
        return false, ViceCity.VehiclesUnsupportedResult('repair')
    end
    local sets, params = {}, {}
    if cfg.engineColumn then
        sets[#sets + 1] = cfg.engineColumn .. ' = ?'; params[#params + 1] = 1000.0
    end
    if cfg.bodyColumn then
        sets[#sets + 1] = cfg.bodyColumn .. ' = ?'; params[#params + 1] = 1000.0
    end
    if cfg.fuelColumn then
        sets[#sets + 1] = cfg.fuelColumn .. ' = ?'; params[#params + 1] = 100.0
    end
    if #sets == 0 then return false, ViceCity.VehiclesUnsupportedResult('repair') end
    params[#params + 1] = plate
    local result, err = ViceCity.Database.Execute(
        ('UPDATE %s SET %s WHERE %s = ?'):format(cfg.table, table.concat(sets, ', '), cfg.plateColumn), params)
    if result == false then return false, { reason = 'provider_error', error = err } end
    TriggerEvent('vicecity:vehicles:updated', plate, 'repaired')
    return true, result
end

-- Global exports: garage-provider-owned first, self-owned SQL store as fallback
-- (see ViceCity.Garage.ServerCreateVehicle/ServerDeleteVehicle/ServerSetVehicleOwner).
local function wrap(ok, result)
    return { ok = ok == true, data = result }
end

exports('CreateVehicle', function(plate, model, owner, garage, props)
    return wrap(ViceCity.Garage.ServerCreateVehicle(plate, model, owner, garage, props))
end)
exports('DeleteVehicle', function(plate)
    return wrap(ViceCity.Garage.ServerDeleteVehicle(plate))
end)
exports('SetVehicleOwner', function(plate, identifier)
    return wrap(ViceCity.Garage.ServerSetVehicleOwner(plate, identifier))
end)
exports('GetVehicle', function(plate) return wrap(ViceCity.Vehicles.Get(plate)) end)
exports('ListVehicles', function(garageId, owner) return wrap(ViceCity.Vehicles.List(garageId, owner)) end)
exports('ListOwnedVehicles', function(owner) return wrap(ViceCity.Vehicles.ListOwned(owner)) end)
exports('CountVehicles', function(owner) return ViceCity.Vehicles.Counts(owner) end)
exports('IsVehicleOwnedBy', function(plate, identifier) return ViceCity.Vehicles.IsOwnedBy(plate, identifier) end)
exports('SetVehicleGarage', function(plate, garageId) return wrap(ViceCity.Vehicles.SetGarage(plate, garageId)) end)
exports('SetVehicleState', function(plate, status) return wrap(ViceCity.Vehicles.SetState(plate, status)) end)
exports('SaveVehicleProperties', function(plate, props) return wrap(ViceCity.Vehicles.SaveProperties(plate, props)) end)
exports('RepairVehicle', function(plate) return wrap(ViceCity.Vehicles.Repair(plate)) end)

