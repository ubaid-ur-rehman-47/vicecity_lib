--[[
    qb-vehiclekeys server adapter.
]]

ViceCityCreateServerVehicleKeysAdapter('qb-vehiclekeys', 'qb-vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['qb-vehiclekeys']:GiveKeys(src, plate) end)
        return ok
    end,

    remove = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['qb-vehiclekeys']:RemoveKeys(src, plate) end)
        return ok
    end,
})
