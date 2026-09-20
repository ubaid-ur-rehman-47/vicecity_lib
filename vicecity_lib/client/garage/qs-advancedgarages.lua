--[[
    qs-advancedgarages client adapter — opens/stores through its own exports.
]]

ViceCityCreateClientGarageAdapter('qs-advancedgarages', 'qs-advancedgarages', {
    capabilities = { open = true, storeVehicle = true },

    open = function(self, garageId)
        return pcall(function() exports['qs-advancedgarages']:OpenGarageMenu(garageId) end)
    end,

    storeVehicle = function(self)
        return pcall(function() exports['qs-advancedgarages']:StoreVehicle() end)
    end,
})
