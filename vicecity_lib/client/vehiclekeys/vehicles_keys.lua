--[[
    vehicles_keys client adapter — self-give/remove via its own raw events.
]]

ViceCityCreateClientVehicleKeysAdapter('vehicles_keys', 'vehicles_keys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
        return true
    end,

    remove = function(self, vehicle, plate)
        TriggerServerEvent('vehicles_keys:selfRemoveKeys', plate)
        return true
    end,
})
