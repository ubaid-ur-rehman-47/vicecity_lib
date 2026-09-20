--[[
    mVehicle server adapter — temporary keys only; cannot revoke keys.
]]

ViceCityCreateServerVehicleKeysAdapter('mVehicle', 'mVehicle', {
    capabilities = { give = true },

    give = function(self, src, vehicle)
        local ok = pcall(function() exports.mVehicle.AddTemporalVehicle(src, vehicle) end)
        return ok
    end,
})
