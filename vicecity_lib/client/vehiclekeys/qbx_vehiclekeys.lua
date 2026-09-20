--[[
    qbx_vehiclekeys client adapter — give/remove need a server-side call (no
    raw client-triggerable event), so this asks vicecity_lib's own server
    layer to mediate through the real qbx_vehiclekeys server export.
]]

ViceCityCreateClientVehicleKeysAdapter('qbx_vehiclekeys', 'qbx_vehiclekeys', {
    capabilities = { give = true, remove = true },

    give = function(self, vehicle)
        if not vehicle or vehicle == 0 then return false, { reason = 'no_vehicle' } end
        TriggerServerEvent('vicecity:vehiclekeys:selfGive', NetworkGetNetworkIdFromEntity(vehicle))
        return true
    end,

    remove = function(self, vehicle)
        if not vehicle or vehicle == 0 then return false, { reason = 'no_vehicle' } end
        TriggerServerEvent('vicecity:vehiclekeys:selfRemove', NetworkGetNetworkIdFromEntity(vehicle))
        return true
    end,
})
