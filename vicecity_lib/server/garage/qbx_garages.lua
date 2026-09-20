--[[
    qbx_garages server adapter — registers custom garage lots.
]]

local sent = {}

local function packVector4(x, y, z, w)
    if vector4 then return vector4(x, y, z, w) end
    return { x = x, y = y, z = z, w = w }
end

ViceCityCreateServerGarageAdapter('qbx_garages', 'qbx_garages', {
    capabilities = { register = true, reset = true },

    register = function(self, lot)
        if not lot or not lot.id then return false, { reason = 'invalid_lot' } end
        if sent[lot.id] then return true end
        local accessPoints = {}
        for i, point in ipairs(lot.points or {}) do
            local sx, sy, sz, sh = ViceCity.GarageSpawnOffset(point.x, point.y, point.z, point.heading)
            accessPoints[i] = {
                coords = packVector4(point.x, point.y, point.z, point.heading),
                spawn = packVector4(sx, sy, sz, sh),
            }
        end
        local ok = pcall(function()
            exports.qbx_garages:RegisterGarage(lot.id, {
                label = lot.label or lot.id,
                type = 'public',
                vehicleType = lot.vehicleType or 'car',
                accessPoints = accessPoints,
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
