--[[
    tgiann-hotwire server adapter — ignition layer only, no give/remove.
]]

ViceCityCreateServerVehicleKeysAdapter('tgiann-hotwire', 'tgiann-hotwire', {
    capabilities = { startIgnition = true, stopIgnition = true },

    startIgnition = function(self, src, vehicle)
        local ok = pcall(function() exports['tgiann-hotwire']:SetKeyInIgnition(nil, vehicle, true) end)
        return ok
    end,

    stopIgnition = function(self, src, vehicle)
        local ok = pcall(function() exports['tgiann-hotwire']:SetKeyInIgnition(nil, vehicle, false) end)
        return ok
    end,
})
