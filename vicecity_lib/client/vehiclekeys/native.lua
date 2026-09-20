--[[
    Native fallback — no vehicle-key resource is running. Every vehicle stays
    driveable without a tracked key, matching un-modded GTA behaviour.
]]

ViceCityCreateClientVehicleKeysAdapter('native', nil, {
    capabilities = { give = true, remove = true, has = true },

    give = function() return true end,
    remove = function() return true end,
    has = function() return true end,
})
