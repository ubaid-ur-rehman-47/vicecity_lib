--[[
    Garage layer (server) — server-side garage facade with normalized API.
    Routes all calls through the detected provider adapter.
]]

local function adapter()
    return ViceCity.GarageAdapter
end

local function call(name, ...)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.Garage.GetProvider() }
    end
    local ok, first, second = pcall(method, provider, ...)
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(first) }
    end
    return first, second
end

ViceCity.Garage = ViceCity.Garage or {}

function ViceCity.Garage.ServerRegister(lot, meta)
    local ok, result = call('register', lot, meta)
    if ok then
        TriggerEvent('vicecity:garage:registered', lot and (lot.id or lot.motelId), ViceCity.Garage.GetProvider())
    end
    return ok, result
end

function ViceCity.Garage.ServerReset()
    return call('reset')
end

function ViceCity.Garage.ServerListVehicles(garageId, owner)
    return call('listVehicles', garageId, owner)
end

function ViceCity.Garage.ServerIsVehicleInGarage(vehicleId)
    return call('isVehicleInGarage', vehicleId)
end

function ViceCity.Garage.ServerGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end
