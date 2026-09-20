--[[
    cd_garage (vehicle-keys role) client adapter — cannot revoke keys.
]]

ViceCityCreateClientVehicleKeysAdapter('cd_garage', 'cd_garage', {
    capabilities = { give = true },

    give = function(self, vehicle, plate)
        TriggerEvent('cd_garage:AddKeys', plate)
        return true
    end,
})
