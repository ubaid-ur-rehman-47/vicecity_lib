--[[
    vehicles_keys server adapter.
]]

ViceCityCreateServerVehicleKeysAdapter('vehicles_keys', 'vehicles_keys', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle, plate)
        local ok = pcall(function()
            exports['vehicles_keys']:giveVehicleKeysToPlayerId(src, plate, 'temporary')
        end)
        return ok
    end,

    remove = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['vehicles_keys']:removeKeysFromPlayerId(src, plate) end)
        return ok
    end,
})
