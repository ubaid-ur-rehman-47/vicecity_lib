--[[
    MrNewbVehicleKeys server adapter.
]]

ViceCityCreateServerVehicleKeysAdapter('MrNewbVehicleKeys', 'MrNewbVehicleKeys', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle, plate)
        local ok = pcall(function() exports.MrNewbVehicleKeys:GiveKeysByPlate(src, plate) end)
        return ok
    end,

    remove = function(self, src, vehicle, plate)
        local ok = pcall(function() exports.MrNewbVehicleKeys:RemoveKeysByPlate(src, plate) end)
        return ok
    end,
})
