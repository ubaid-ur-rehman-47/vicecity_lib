-- -- Use this file to add support for another inventory by simply copying the file and replacing the logic within the functions
-- local found = GetResourceState('ps-inventory')
-- if found ~= 'started' and found ~= 'starting' then return end

-- nass.inventorySystem = 'ps-inventory'
-- nass.inventory = {}

-- OldInventory = GetResourceMetadata(nass.inventorySystem, 'version', 0)
-- OldInventory = OldInventory:gsub('%.', '')
-- OldInventory = tonumber(OldInventory)
-- if not OldInventory or OldInventory >= 105 then OldInventory = false end

-- function nass.inventory.openPlayerInventory(targetId)
--     if not OldInventory then
--         TriggerServerEvent('nass_lib:openPlayerInventory', targetId)
--         return
--     end

--     TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', targetId)
--     TriggerEvent('inventory:server:RobPlayer', targetId)
-- end

-- function nass.inventory.openStash(data)
--     -- data = {name = name, unique = true, maxWeight = maxWeight, slots = slots}
--     if data.unique then
--         data.name = ('%s_%s'):format(data.name, nass.getIdentifier())
--     end

--     if not OldInventory then
--         TriggerServerEvent('nass_lib:openStash', data)
--         return
--     end

--     TriggerServerEvent('inventory:server:OpenInventory', 'stash', data.name,
--         { maxweight = data.maxWeight, slots = data.slots })
--     TriggerEvent('inventory:client:SetCurrentStash', data.name)
-- end

-- function nass.inventory.openShop(data)
--     --[[
-- data = {
--     identifier = 'shop_identifier',
--     name = 'Shop Name',
--     inventory = {
--         { name = 'item_name', price = 100 },
--     },
--     locations = {
--         vec3(0, 0, 0),
--     }
-- ]]

--     if not OldInventory then
--         TriggerServerEvent('nass_lib:registerShop', data)
--         return
--     end

--     local shopData = ConvertShopData(data)

--     TriggerServerEvent("inventory:server:OpenInventory", "shop", data.identifier, shopData)
-- end
