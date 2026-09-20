--[[
    cd_garage (vehicle-keys role) server adapter — cannot revoke keys.
]]

ViceCityCreateServerVehicleKeysAdapter('cd_garage', 'cd_garage', {
    capabilities = { give = true },

    give = function(self, src, vehicle, plate)
        TriggerClientEvent('cd_garage:AddKeys', src, plate)
        return true
    end,
})
