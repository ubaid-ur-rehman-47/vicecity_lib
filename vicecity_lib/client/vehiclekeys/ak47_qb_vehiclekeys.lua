--[[
    ak47_qb_vehiclekeys client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('ak47_qb_vehiclekeys', 'ak47_qb_vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function()
            exports['ak47_qb_vehiclekeys']:GiveKey(plate, not NetworkGetEntityIsNetworked(vehicle))
        end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function()
            exports['ak47_qb_vehiclekeys']:RemoveKey(plate, not NetworkGetEntityIsNetworked(vehicle))
        end)
        return ok
    end,
})
