--[[
    ND_Core server adapter — loads ND_Core's own init.lua lazily so this
    works without ox_lib, matching ND_Core's own loading convention.
]]

local loaded = false
local function ensureLoaded()
    if loaded then return end
    NDCore = NDCore or {}
    local chunk = LoadResourceFile('ND_Core', 'init.lua')
    if chunk then
        local fn = load(chunk, '@@ND_Core/init.lua')
        if fn then fn() end
    end
    loaded = true
end

ViceCityCreateServerVehicleKeysAdapter('ND_Core', 'ND_Core', {
    capabilities = { give = true, remove = true },

    give = function(self, src, vehicle)
        ensureLoaded()
        local ok = pcall(function() NDCore.giveVehicleAccess(src, vehicle, true) end)
        return ok
    end,

    remove = function(self, src, vehicle)
        ensureLoaded()
        local ok = pcall(function() NDCore.giveVehicleAccess(src, vehicle, false) end)
        return ok
    end,
})
