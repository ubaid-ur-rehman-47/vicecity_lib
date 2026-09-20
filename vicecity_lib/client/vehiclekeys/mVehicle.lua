--[[
    mVehicle client adapter — temporary keys only; cannot revoke keys.
]]

ViceCityCreateClientVehicleKeysAdapter('mVehicle', 'mVehicle', {
    capabilities = { give = true },

    give = function(self, vehicle)
        local ok = pcall(function() exports.mVehicle:AddTemporalVehicleClient(vehicle) end)
        return ok
    end,
})
