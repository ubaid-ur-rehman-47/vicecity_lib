-- -- Use this file to add support for another inventory by simply copying the file and replacing the logic within the functions
-- local found = GetResourceState('ox_inventory')
-- if found ~= 'started' and found ~= 'starting' then return end

-- nass.inventorySystem = 'ox_inventory'
-- nass.inventory = {}

-- local registeredStashes = {}
-- local registeredShops = {}

-- function nass.inventory.getItemSlot(source, item)
--     return exports.ox_inventory:GetSlotIdWithItem(source, item) or false
-- end

-- function nass.inventory.getItemMetadata(source, slot)
--     local item = exports.ox_inventory:GetSlot(source, slot)
--     return item.metadata
-- end

-- function nass.inventory.setItemMetadata(source, slot, metadata)
--     return exports.ox_inventory:SetMetadata(source, slot, metadata)
-- end

-- ---Clears specified inventory
-- ---@param source number
-- ---@param keepItems string | table
-- function nass.inventory.clearInventory(source, identifier, keepItems)
--     exports.ox_inventory:ClearInventory(source, keepItems)
-- end

-- nass.createCallback('nass_lib:registerStash', function(_source, cb, data)
--     if registeredStashes[data.name] then
--         cb(true)
--         return
--     end
--     exports.ox_inventory:RegisterStash(data.name, data.name, data.slots, data.maxWeight, data.unique or false, nil, nil)
--     registeredStashes[data.name] = true
--     cb(true)
-- end)

-- nass.createCallback('nass_lib:registerShop', function(_source, cb, data)
--     if registeredShops[data.identifier] then
--         cb(true)
--         return
--     end

--     exports.ox_inventory:RegisterShop(data.identifier, {
--         name = data.name,
--         inventory = data.inventory,
--         locations = data.locations
--     })
--     cb(true)
-- end)
