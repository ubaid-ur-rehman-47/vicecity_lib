--[[
    Garage provider helper for server adapters.
    Creates a basic server adapter factory.
]]

local function createServerGarageAdapter(name, resource, options)
    options = options or {}
    local adapter = {
        name = name,
        resource = resource,
        capabilities = options.capabilities or {
            register = true,
            reset = true,
        },
    }

    function adapter:register(lot, meta)
        if options.register then return options.register(self, lot, meta) end
        return false, { reason = 'unsupported', operation = 'register', provider = self.name }
    end

    function adapter:reset()
        if options.reset then return options.reset(self) end
        return false, { reason = 'unsupported', operation = 'reset', provider = self.name }
    end

    function adapter:listVehicles(garageId, owner)
        if options.listVehicles then return options.listVehicles(self, garageId, owner) end
        return false, { reason = 'unsupported', operation = 'listVehicles', provider = self.name }
    end

    function adapter:isVehicleInGarage(vehicleId)
        if options.isVehicleInGarage then return options.isVehicleInGarage(self, vehicleId) end
        return false, { reason = 'unsupported', operation = 'isVehicleInGarage', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('garage', name, adapter)
end

ViceCityCreateServerGarageAdapter = createServerGarageAdapter
