--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

RegisterNetEvent("ox_inventory:throwHit", function(targetServerId, velocity)
    local src = source
    if type(targetServerId) == "number" then
        TriggerClientEvent("ox_inventory:throwHit", targetServerId, velocity)
    end
end)

RegisterNetEvent("ox_inventory:throwItem", function(slot, coords, model)
    local src = source
    local item = exports.ox_inventory:GetSlot(src, slot)

    if not item or item.count < 1 then return end

    local success = exports.ox_inventory:RemoveItem(src, item.name, 1, item.metadata, slot)

    if success then
        local spawnCoords = vec3(coords.x, coords.y, coords.z + 0.2)

        exports.ox_inventory:CustomDrop("Throw", {
            { item.name, 1, item.metadata }
        }, spawnCoords, nil, nil, nil, model)
    end
end)

lib.callback.register("ox_inventory:pickupThrownDrop", function(source, dropId)
    local src = source
    return true
end)
