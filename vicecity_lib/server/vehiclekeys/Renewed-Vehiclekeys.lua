--[[
    Renewed-Vehiclekeys server adapter.
]]

ViceCityCreateServerVehicleKeysAdapter('Renewed-Vehiclekeys', 'Renewed-Vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['Renewed-Vehiclekeys']:addKey(src, plate) end)
        return ok
    end,

    remove = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['Renewed-Vehiclekeys']:removeKey(src, plate) end)
        return ok
    end,
})
