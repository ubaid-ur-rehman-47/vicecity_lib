--[[
    Vehicle-keys provider helper for server adapters.
    Creates a full adapter factory plus a thin client-forwarding factory for
    providers whose key state only exists on the client.
]]

local function createServerVehicleKeysAdapter(name, resource, options)
    options = options or {}
    local adapter = {
        name = name,
        resource = resource,
        clientOnly = false,
        capabilities = options.capabilities or { give = true, remove = true },
    }

    function adapter:give(src, vehicle, plate)
        if options.give then return options.give(self, src, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'give', provider = self.name }
    end

    function adapter:remove(src, vehicle, plate)
        if options.remove then return options.remove(self, src, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'remove', provider = self.name }
    end

    function adapter:startIgnition(src, vehicle, plate)
        if options.startIgnition then return options.startIgnition(self, src, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'startIgnition', provider = self.name }
    end

    function adapter:stopIgnition(src, vehicle, plate)
        if options.stopIgnition then return options.stopIgnition(self, src, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'stopIgnition', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('vehiclekeys', name, adapter)
end

-- Providers with no server-side key API: the server forwards give/remove to
-- the target player's client, which applies it through the same provider.
local function createClientOnlyVehicleKeysAdapter(name, resource)
    local adapter = {
        name = name,
        resource = resource,
        clientOnly = true,
        capabilities = { give = true, remove = true },
    }

    local function forward(src, verb, vehicle, plate)
        if not src or not vehicle or not DoesEntityExist(vehicle) then
            return false, { reason = 'invalid_vehicle', operation = verb, provider = name }
        end
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        if not netId or netId <= 0 then
            return false, { reason = 'invalid_vehicle', operation = verb, provider = name }
        end
        TriggerClientEvent('vicecity:vehiclekeys:apply', src, verb, netId, plate)
        return true
    end

    function adapter:give(src, vehicle, plate)
        return forward(src, 'give', vehicle, plate)
    end

    function adapter:remove(src, vehicle, plate)
        return forward(src, 'remove', vehicle, plate)
    end

    function adapter:getRaw()
        return nil
    end

    ViceCity.RegisterProvider('vehiclekeys', name, adapter)
end

ViceCityCreateServerVehicleKeysAdapter = createServerVehicleKeysAdapter
ViceCityCreateClientOnlyVehicleKeysAdapter = createClientOnlyVehicleKeysAdapter
