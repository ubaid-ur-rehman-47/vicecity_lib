--[[
    qs-vehiclekeys client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('qs-vehiclekeys', 'qs-vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function()
            exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true)
        end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function()
            exports['qs-vehiclekeys']:RemoveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
        end)
        return ok
    end,
})
