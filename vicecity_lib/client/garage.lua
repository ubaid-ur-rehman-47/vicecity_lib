--[[
    Garage layer (client) — client-side garage facade with normalized API.
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

function ViceCity.Garage.ClientOpen(garageId, spot)
    return call('open', garageId, spot)
end

function ViceCity.Garage.ClientListVehicles(garageId)
    return call('listVehicles', garageId)
end

function ViceCity.Garage.ClientStoreVehicle(vehicle, garageId)
    return call('storeVehicle', vehicle, garageId)
end

function ViceCity.Garage.ClientRetrieveVehicle(vehicleId, garageId, spawnPoint)
    return call('retrieveVehicle', vehicleId, garageId, spawnPoint)
end

function ViceCity.Garage.ClientGetNearby(coords, radius)
    return call('getNearby', coords, radius)
end

function ViceCity.Garage.ClientGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end
