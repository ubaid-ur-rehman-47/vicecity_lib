--[[
    0r-vehiclekeys client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('0r-vehiclekeys', '0r-vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function() exports['0r-vehiclekeys']:GiveKeys(plate) end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function() exports['0r-vehiclekeys']:RemoveKeys(plate) end)
        return ok
    end,
})
