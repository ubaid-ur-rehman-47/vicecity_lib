--[[
    MrNewbVehicleKeys client adapter.
]]

ViceCityCreateClientVehicleKeysAdapter('MrNewbVehicleKeys', 'MrNewbVehicleKeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function() exports.MrNewbVehicleKeys:GiveKeysByPlate(plate) end)
        return ok
    end,

    remove = function(self, vehicle, plate)
        local ok = pcall(function() exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate) end)
        return ok
    end,
})
