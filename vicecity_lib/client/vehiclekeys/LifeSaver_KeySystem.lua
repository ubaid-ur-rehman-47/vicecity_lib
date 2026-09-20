--[[
    LifeSaver_KeySystem client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('LifeSaver_KeySystem', 'LifeSaver_KeySystem', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function()
            exports['LifeSaver_KeySystem']:AddCarkey(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
        end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function()
            exports['LifeSaver_KeySystem']:RemoveCarkey(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)))
        end)
        return ok
    end,
})
