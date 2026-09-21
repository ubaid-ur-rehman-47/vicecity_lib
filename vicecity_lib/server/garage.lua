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

-- Provider-owned first (the active garage resource's own vehicle CRUD, if it
-- exposes one); falls back to vicecity_lib's own self-owned vehicle store so
-- CRUD always works even when the garage resource has no public CRUD export.
function ViceCity.Garage.ServerCreateVehicle(plate, model, owner, garage, props)
    local ok, result = call('createVehicle', plate, model, owner, garage, props)
    if ok ~= false or type(result) ~= 'table' or result.reason ~= 'unsupported' then return ok, result end
    return ViceCity.Vehicles.Create(plate, model, owner, garage, props)
end

function ViceCity.Garage.ServerDeleteVehicle(plate)
    local ok, result = call('deleteVehicle', plate)
    if ok ~= false or type(result) ~= 'table' or result.reason ~= 'unsupported' then return ok, result end
    return ViceCity.Vehicles.Delete(plate)
end

function ViceCity.Garage.ServerSetVehicleOwner(plate, identifier)
    local ok, result = call('setVehicleOwner', plate, identifier)
    if ok ~= false or type(result) ~= 'table' or result.reason ~= 'unsupported' then return ok, result end
    return ViceCity.Vehicles.SetOwner(plate, identifier)
end

function ViceCity.Garage.ServerGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end
