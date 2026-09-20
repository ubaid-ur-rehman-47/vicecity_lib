--[[
    okokGarage client adapter — give/remove via its own raw events.
]]

ViceCityCreateClientVehicleKeysAdapter('okokGarage', 'okokGarage', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        TriggerServerEvent('okokGarage:GiveKeys', plate)
        return true
    end,

    remove = function(self, vehicle, plate)
        TriggerServerEvent('okokGarage:RemoveKeys', plate, GetPlayerServerId(PlayerId()))
        return true
    end,
})
