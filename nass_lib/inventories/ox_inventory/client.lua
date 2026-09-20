-- -- Use this file to add support for another inventory by simply copying the file and replacing the logic within the functions
-- local found = GetResourceState('ox_inventory')
-- if found ~= 'started' and found ~= 'starting' then return end

-- nass.inventorySystem = 'ox_inventory'
-- nass.inventory = {}

-- function nass.inventory.openPlayerInventory(targetId)
--     exports.ox_inventory:openInventory('player', targetId)
-- end

-- function nass.inventory.openStash(data)
--     -- data = {name = name, unique = true, maxWeight = maxWeight, slots = slots}
--     local stashRegistered = nass.awaitServerCallback('nass_lib:registerStash', data)
--     if not stashRegistered then return end

--     exports.ox_inventory:openInventory('stash', data.name)
-- end

-- function nass.inventory.openShop(data)
--     --[[
-- data = {
--     identifier = 'shop_identifier',
--     name = 'Shop Name',
--     inventory = {
--         { name = 'item_name', price = 100 },
--     }
-- }
-- ]]
--     local shopRegistered = nass.awaitServerCallback('nass_lib:registerShop', data)
--     if not shopRegistered then return end

--     exports.ox_inventory:openInventory('shop', { type = data.identifier, id = 1 })
-- end
