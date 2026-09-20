--[[
    Vehicle persistence layer (shared) — normalized vehicle record contract.
    Persistence is provider-owned by default (the active garage provider keeps
    its own vehicle table); an optional SQL fallback is used only when
    `ViceCityConfig.vehicles.sqlFallback` is explicitly configured.

    Global API:
      ViceCity.Vehicles.*   server vehicle read/write operations
]]

ViceCity.Vehicles = ViceCity.Vehicles or {}

local function createVehicleRecord(plate, model, owner, garage, status)
    return {
        plate = plate,
        model = model,
        owner = owner,
        garage = garage,
        status = status or 'garage',
        type = nil,
        fuel = nil,
        engine = nil,
        body = nil,
        props = nil,
        raw = nil,
    }
end

local function unsupportedResult(operation, provider)
    return { ok = false, reason = 'unsupported', operation = operation, provider = provider or 'sql' }
end

-- Trims and upper-cases a plate the same way every reference provider does,
-- so a lookup by plate matches regardless of who stored the record.
local function normalizePlate(plate)
    if type(plate) ~= 'string' then return nil end
    return plate:gsub('%s+', ''):upper()
end

ViceCity.VehiclesCreateRecord = createVehicleRecord
ViceCity.VehiclesUnsupportedResult = unsupportedResult
ViceCity.VehiclesNormalizePlate = normalizePlate
