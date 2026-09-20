--[[
    Garage provider helper for client adapters.
    Creates a basic client adapter factory.
]]

local function createClientGarageAdapter(name, resource, options)
    options = options or {}
    local adapter = {
        name = name,
        resource = resource,
        capabilities = options.capabilities or {
            open = true,
            listVehicles = true,
            storeVehicle = true,
            retrieveVehicle = true,
        },
    }

    function adapter:open(garageId, spot)
        if options.open then return options.open(self, garageId, spot) end
        return false, { reason = 'unsupported', operation = 'open', provider = self.name }
    end

    function adapter:listVehicles(garageId)
        if options.listVehicles then return options.listVehicles(self, garageId) end
        return false, { reason = 'unsupported', operation = 'listVehicles', provider = self.name }
    end

    function adapter:storeVehicle(vehicle, garageId)
        if options.storeVehicle then return options.storeVehicle(self, vehicle, garageId) end
        return false, { reason = 'unsupported', operation = 'storeVehicle', provider = self.name }
    end

    function adapter:retrieveVehicle(vehicleId, garageId, spawnPoint)
        if options.retrieveVehicle then return options.retrieveVehicle(self, vehicleId, garageId, spawnPoint) end
        return false, { reason = 'unsupported', operation = 'retrieveVehicle', provider = self.name }
    end

    function adapter:getNearby(coords, radius)
        if options.getNearby then return options.getNearby(self, coords, radius) end
        return false, { reason = 'unsupported', operation = 'getNearby', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('garage', name, adapter)
end

ViceCityCreateClientGarageAdapter = createClientGarageAdapter
