--[[
    qb-vehiclekeys client adapter — give/remove use its own raw events.
]]

ViceCityCreateClientVehicleKeysAdapter('qb-vehiclekeys', 'qb-vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle, plate)
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
        return true
    end,

    remove = function(self, vehicle, plate)
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
        return true
    end,
})
