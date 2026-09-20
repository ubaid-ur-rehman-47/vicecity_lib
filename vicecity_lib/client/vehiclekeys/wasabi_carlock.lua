--[[
    wasabi_carlock client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('wasabi_carlock', 'wasabi_carlock', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function() exports.wasabi_carlock:GiveKey(plate) end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function() exports.wasabi_carlock:RemoveKey(plate) end)
        return ok
    end,
})
