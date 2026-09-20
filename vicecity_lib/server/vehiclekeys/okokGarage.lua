--[[
    okokGarage server adapter.
]]

ViceCityCreateServerVehicleKeysAdapter('okokGarage', 'okokGarage', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle, plate)
        TriggerEvent('okokGarage:GiveKeys', plate)
        return true
    end,

    remove = function(self, src, vehicle, plate)
        TriggerEvent('okokGarage:RemoveKeys', plate, src)
        return true
    end,
})
