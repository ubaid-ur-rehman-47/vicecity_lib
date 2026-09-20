--[[
    qbx_vehiclekeys server adapter — real server-side give/remove exports.
]]

ViceCityCreateServerVehicleKeysAdapter('qbx_vehiclekeys', 'qbx_vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle)
        local ok = pcall(function() exports['qbx_vehiclekeys']:GiveKeys(src, vehicle) end)
        return ok
    end,

    remove = function(self, src, vehicle)
        local ok = pcall(function() exports['qbx_vehiclekeys']:RemoveKeys(src, vehicle) end)
        return ok
    end,
})
