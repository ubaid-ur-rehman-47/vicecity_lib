--[[
    wasabi_carlock server adapter.
]]

ViceCityCreateServerVehicleKeysAdapter('wasabi_carlock', 'wasabi_carlock', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['wasabi_carlock']:GiveKey(plate, src) end)
        return ok
    end,

    remove = function(self, src, vehicle, plate)
        local ok = pcall(function() exports['wasabi_carlock']:RemoveKey(plate, src) end)
        return ok
    end,
})
