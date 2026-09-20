--[[
    cd_garage client adapter — opens/stores through cd_garage's own events.
]]

ViceCityCreateClientGarageAdapter('cd_garage', 'cd_garage', {
    capabilities = { open = true, storeVehicle = true },

    open = function(self, garageId, spawnPoint)
        TriggerEvent('cd_garage:PropertyGarage:Open', spawnPoint)
        return true
    end,

    storeVehicle = function(self)
        TriggerEvent('cd_garage:PropertyGarage:StoreVehicle')
        return true
    end,
})
