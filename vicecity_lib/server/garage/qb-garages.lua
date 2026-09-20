--[[
    qb-garages server adapter — registers custom garage lots (house garage).
]]

local sent = {}

ViceCityCreateServerGarageAdapter('qb-garages', 'qb-garages', {
    capabilities = { register = true, reset = true },

    register = function(self, lot)
        if not lot or not lot.id then return false, { reason = 'invalid_lot' } end
        if sent[lot.id] then return true end
        local point = lot.points and lot.points[1]
        if not point then return false, { reason = 'invalid_lot' } end
        local sx, sy, sz, sh = ViceCity.GarageSpawnOffset(point.x, point.y, point.z, point.heading)
        TriggerClientEvent('qb-garages:client:addHouseGarage', -1, lot.id, {
            takeVehicle = { x = sx, y = sy, z = sz, w = sh },
            spawnPoint = { { x = sx, y = sy, z = sz, w = sh } },
            label = lot.label or lot.id,
            type = 'public',
            category = lot.vehicleType or 'car',
        })
        sent[lot.id] = true
        return true
    end,

    reset = function(self)
        sent = {}
        return true
    end,
})
