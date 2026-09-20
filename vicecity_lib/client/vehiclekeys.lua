--[[
    Vehicle-keys layer (client) — client-side key facade with normalized API.
    Routes all calls through the detected provider adapter.
]]

local function adapter()
    return ViceCity.VehicleKeysAdapter
end

local function plateOf(vehicle, plate)
    if plate then return plate end
    if vehicle and vehicle ~= 0 and DoesEntityExist(vehicle) then
        return GetVehicleNumberPlateText(vehicle)
    end
    return nil
end

local function call(name, vehicle, plate)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.VehicleKeys.GetProvider() }
    end
    local ok, first, second = pcall(method, provider, vehicle, plateOf(vehicle, plate))
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(first) }
    end
    return first, second
end

ViceCity.VehicleKeys = ViceCity.VehicleKeys or {}

function ViceCity.VehicleKeys.ClientGive(vehicle, plate)
    return call('give', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientRemove(vehicle, plate)
    return call('remove', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientHas(vehicle, plate)
    return call('has', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientLock(vehicle, plate)
    return call('lock', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientUnlock(vehicle, plate)
    return call('unlock', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientToggleLock(vehicle, plate)
    return call('toggleLock', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientStartIgnition(vehicle, plate)
    return call('startIgnition', vehicle, plate)
end

function ViceCity.VehicleKeys.ClientGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end

-- The server forwards here when the active provider only has a client API.
RegisterNetEvent('vicecity:vehiclekeys:apply', function(verb, netId, plate)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle == 0 then return end
    if verb == 'give' then
        ViceCity.VehicleKeys.ClientGive(vehicle, plate)
    elseif verb == 'remove' then
        ViceCity.VehicleKeys.ClientRemove(vehicle, plate)
    end
end)

GiveVehicleKeys = function(vehicle, plate) return ViceCity.VehicleKeys.ClientGive(vehicle, plate) end
RemoveVehicleKeys = function(vehicle, plate) return ViceCity.VehicleKeys.ClientRemove(vehicle, plate) end
