--[[
    qs-advancedgarages server adapter — registers custom garage lots.
]]

local sent = {}

ViceCityCreateServerGarageAdapter('qs-advancedgarages', 'qs-advancedgarages', {
    capabilities = { register = true, reset = true },

    register = function(self, lot)
        if not lot or not lot.id then return false, { reason = 'invalid_lot' } end
        if sent[lot.id] then return true end
        local point = lot.points and lot.points[1]
        if not point then return false, { reason = 'invalid_lot' } end
        local sx, sy, sz, sh = ViceCity.GarageSpawnOffset(point.x, point.y, point.z, point.heading)
        local ok = pcall(function()
            exports['qs-advancedgarages']:CreateGarage(lot.id, {
                owner = false,
                available = true,
                type = 'vehicle',
                coords = {
                    menuCoords = { x = point.x, y = point.y, z = point.z },
                    spawnCoords = { x = sx, y = sy, z = sz, w = sh },
                },
                price = 0,
            })
        end)
        if ok then sent[lot.id] = true end
        return ok
    end,

    reset = function(self)
        sent = {}
        return true
    end,
})
