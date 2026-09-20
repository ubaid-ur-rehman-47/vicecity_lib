--[[
    cd_garage server adapter — registers custom garage lots.
]]

local sent = {}

ViceCityCreateServerGarageAdapter('cd_garage', 'cd_garage', {
    capabilities = { register = true, reset = true },

    register = function(self, lot)
        if not lot or not lot.id then return false, { reason = 'invalid_lot' } end
        if sent[lot.id] then return true end
        local point = lot.points and lot.points[1]
        if not point then return false, { reason = 'invalid_lot' } end
        local sx, sy, sz, sh = ViceCity.GarageSpawnOffset(point.x, point.y, point.z, point.heading)
        TriggerEvent('cd_garage:PropertyGarage:Create', {
            garage_label = lot.label or lot.id,
            allowed_vehicle_types = { lot.vehicleType or 'car' },
            coords = {
                open = { x = point.x, y = point.y, z = point.z, interact_distance = 0.05, view_distance = 15 },
                spawn = { x = sx, y = sy, z = sz, heading = sh },
            },
            blip = { enabled = false },
        })
        sent[lot.id] = true
        return true
    end,

    reset = function(self)
        sent = {}
        return true
    end,
})
