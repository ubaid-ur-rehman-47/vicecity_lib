--[[
    Vehicle-keys provider helper for client adapters.
    Creates a basic client adapter factory.
]]

local function createClientVehicleKeysAdapter(name, resource, options)
    options = options or {}
    local adapter = {
        name = name,
        resource = resource,
        capabilities = options.capabilities or { give = true, remove = true },
    }

    function adapter:give(vehicle, plate)
        if options.give then return options.give(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'give', provider = self.name }
    end

    function adapter:remove(vehicle, plate)
        if options.remove then return options.remove(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'remove', provider = self.name }
    end

    function adapter:has(vehicle, plate)
        if options.has then return options.has(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'has', provider = self.name }
    end

    function adapter:lock(vehicle, plate)
        if options.lock then return options.lock(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'lock', provider = self.name }
    end

    function adapter:unlock(vehicle, plate)
        if options.unlock then return options.unlock(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'unlock', provider = self.name }
    end

    function adapter:toggleLock(vehicle, plate)
        if options.toggleLock then return options.toggleLock(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'toggleLock', provider = self.name }
    end

    function adapter:startIgnition(vehicle, plate)
        if options.startIgnition then return options.startIgnition(self, vehicle, plate) end
        return false, { reason = 'unsupported', operation = 'startIgnition', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('vehiclekeys', name, adapter)
end

ViceCityCreateClientVehicleKeysAdapter = createClientVehicleKeysAdapter
