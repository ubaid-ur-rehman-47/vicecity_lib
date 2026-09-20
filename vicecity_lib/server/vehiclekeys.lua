--[[
    Vehicle-keys layer (server) — server-side key facade with normalized API.
    Validates the vehicle entity before every mutation and routes calls
    through the detected provider adapter.
]]

local function adapter()
    return ViceCity.VehicleKeysAdapter
end

local function call(name, src, vehicle, plate)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.VehicleKeys.GetProvider() }
    end
    local ok, first, second = pcall(method, provider, src, vehicle, plate)
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(first) }
    end
    return first, second
end

-- tgiann-hotwire is a separate ignition layer that can sit on top of any
-- other main key provider; apply it in addition when both are configured.
local function applyHotwireIgnition(vehicle)
    local config = ViceCityConfig.vehicleKeys or {}
    if config.hotwireIgnition == false then return end
    if ViceCity.VehicleKeys.GetProvider() == 'tgiann-hotwire' then return end
    if GetResourceState('tgiann-hotwire') ~= 'started' then return end
    local hotwire = ViceCity.Providers.vehiclekeys and ViceCity.Providers.vehiclekeys['tgiann-hotwire']
    if hotwire and hotwire.startIgnition then
        pcall(function() hotwire:startIgnition(nil, vehicle) end)
    end
end

ViceCity.VehicleKeys = ViceCity.VehicleKeys or {}

function ViceCity.VehicleKeys.ServerGive(src, vehicle, plate)
    local ok, result = call('give', src, vehicle, plate)
    if ok then
        if vehicle and vehicle ~= 0 then applyHotwireIgnition(vehicle) end
        TriggerEvent('vicecity:vehiclekeys:given', src, plate, ViceCity.VehicleKeys.GetProvider())
    end
    return ok, result
end

function ViceCity.VehicleKeys.ServerRemove(src, vehicle, plate)
    local ok, result = call('remove', src, vehicle, plate)
    if ok then
        TriggerEvent('vicecity:vehiclekeys:removed', src, plate, ViceCity.VehicleKeys.GetProvider())
    end
    return ok, result
end

function ViceCity.VehicleKeys.ServerShare(fromSource, toSource, vehicle, plate)
    return ViceCity.VehicleKeys.ServerGive(toSource, vehicle, plate)
end

function ViceCity.VehicleKeys.ServerRevoke(src, vehicle, plate)
    return ViceCity.VehicleKeys.ServerRemove(src, vehicle, plate)
end

function ViceCity.VehicleKeys.ServerGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end

-- Self-service give/remove for providers whose only mutation API is a
-- server export (qbx_vehiclekeys, ND_Core): the client asks its own server
-- to apply keys to itself for a vehicle it already controls.
RegisterNetEvent('vicecity:vehiclekeys:selfGive', function(netId)
    local source = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle ~= 0 then ViceCity.VehicleKeys.ServerGive(source, vehicle) end
end)

RegisterNetEvent('vicecity:vehiclekeys:selfRemove', function(netId)
    local source = source
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    if vehicle ~= 0 then ViceCity.VehicleKeys.ServerRemove(source, vehicle) end
end)

GiveVehicleKeys = function(src, vehicle, plate) return ViceCity.VehicleKeys.ServerGive(src, vehicle, plate) end
RemoveVehicleKeys = function(src, vehicle, plate) return ViceCity.VehicleKeys.ServerRemove(src, vehicle, plate) end
