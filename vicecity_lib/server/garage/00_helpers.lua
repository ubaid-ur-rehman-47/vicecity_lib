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

    function adapter:createVehicle(plate, model, owner, garage, props)
        if options.createVehicle then return options.createVehicle(self, plate, model, owner, garage, props) end
        return false, { reason = 'unsupported', operation = 'createVehicle', provider = self.name }
    end

    function adapter:deleteVehicle(plate)
        if options.deleteVehicle then return options.deleteVehicle(self, plate) end
        return false, { reason = 'unsupported', operation = 'deleteVehicle', provider = self.name }
    end

    function adapter:setVehicleOwner(plate, identifier)
        if options.setVehicleOwner then return options.setVehicleOwner(self, plate, identifier) end
        return false, { reason = 'unsupported', operation = 'setVehicleOwner', provider = self.name }
    end

    function adapter:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('garage', name, adapter)
end

ViceCityCreateServerGarageAdapter = createServerGarageAdapter
