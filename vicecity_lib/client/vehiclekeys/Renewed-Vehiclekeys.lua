--[[
    Renewed-Vehiclekeys client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('Renewed-Vehiclekeys', 'Renewed-Vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function() exports['Renewed-Vehiclekeys']:addKey(plate) end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function() exports['Renewed-Vehiclekeys']:removeKey(plate) end)
        return ok
    end,
})
