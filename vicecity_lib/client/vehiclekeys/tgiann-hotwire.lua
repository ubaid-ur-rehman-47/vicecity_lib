--[[
    tgiann-hotwire client adapter — a separate ignition layer: gives a key
    and puts it in the ignition, but cannot revoke a key once placed.
]]

ViceCityCreateClientVehicleKeysAdapter('tgiann-hotwire', 'tgiann-hotwire', {
    capabilities = { give = true, startIgnition = true },

    give = function(self, vehicle, plate)
        local ok = pcall(function() exports['tgiann-hotwire']:GiveKeyPlate(plate, true) end)
        return ok
    end,

    startIgnition = function(self, vehicle)
        local ok = pcall(function() exports['tgiann-hotwire']:SetKeyInIgnition(vehicle, false) end)
        return ok
    end,
})
