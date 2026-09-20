--[[
    Native fallback — no vehicle-key resource is running; give/remove are
    always trivially satisfied server-side too.
]]

ViceCityCreateServerVehicleKeysAdapter('native', nil, {
    capabilities = { give = true, remove = true },

    give = function() return true end,
    remove = function() return true end,
})
