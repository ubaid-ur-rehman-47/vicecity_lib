--[[
    Garage layer (shared) — normalized garage-lot and vehicle-slot contract
    across all supported garage providers.

    Global API:
      ViceCity.Garage.*        client/server garage operations
      ViceCity.GarageAdapter   registration point for custom providers
]]

ViceCity.Garage = ViceCity.Garage or {}

-- Garage lot types
local GARAGE_TYPES = {
    public = 'public',
    house = 'house',
    job = 'job',
    gang = 'gang',
    impound = 'impound',
}

-- Vehicle status while tracked by a garage
local VEHICLE_STATUS = {
    garage = 'garage',
    outside = 'outside',
    impound = 'impound',
}

-- Normalized garage lot structure
local function createGarageLot(id, label, garageType, vehicleType, points)
    return {
        id = id,
        label = label or id,
        type = garageType or GARAGE_TYPES.public,
        vehicleType = vehicleType or 'car',
        points = points or {},
        raw = nil,
    }
end

local function unsupportedResult(operation, provider)
    return { ok = false, reason = 'unsupported', operation = operation, provider = provider }
end

local function forbiddenResult(operation, reason)
    return { ok = false, reason = reason or 'forbidden', operation = operation }
end

-- Offsets a garage point 3.5 units along its heading — the common spawn
-- offset every reference garage provider uses so vehicles don't clip a wall.
local function spawnOffset(x, y, z, heading)
    local h = (tonumber(heading) or 0.0) + 0.0
    local px = (tonumber(x) or 0.0) + 0.0
    local py = (tonumber(y) or 0.0) + 0.0
    local pz = (tonumber(z) or 0.0) + 0.0
    local rad = math.rad(h)
    return px - math.sin(rad) * 3.5, py + math.cos(rad) * 3.5, pz, h
end

ViceCity.GarageTypes = GARAGE_TYPES
ViceCity.GarageVehicleStatus = VEHICLE_STATUS
ViceCity.GarageCreateLot = createGarageLot
ViceCity.GarageUnsupportedResult = unsupportedResult
ViceCity.GarageForbiddenResult = forbiddenResult
ViceCity.GarageSpawnOffset = spawnOffset

function ViceCity.Garage.GetProvider()
    return ViceCity.GetProvider('garage') or 'none'
end

function ViceCity.Garage.GetCapabilities()
    local provider = ViceCity.GarageAdapter
    return provider and provider.capabilities or {}
end

GetGarageProvider = ViceCity.Garage.GetProvider
GetGarageCapabilities = ViceCity.Garage.GetCapabilities
