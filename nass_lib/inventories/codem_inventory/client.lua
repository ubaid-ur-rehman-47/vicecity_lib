-- Use this file to add support for another inventory by simply copying the file and replacing the logic within the functions
-- local found = GetResourceState('codem-inventory')
-- if found ~= 'started' and found ~= 'starting' then return end

nass.inventorySystem = 'codem-inventory'
nass.inventory = {}

function nass.inventory.openPlayerInventory(targetId)
    TriggerServerEvent('codem-inventory:server:robplayer', targetId)
end

function nass.inventory.openStash(data)
    -- data = {name = name, unique = true, maxWeight = maxWeight, slots = slots}
    if data.unique then
        data.name = ('%s_%s'):format(data.name, nass.getIdentifier())
    end

    TriggerServerEvent('inventory:server:OpenInventory', 'stash', data.name,
        { maxweight = data.maxWeight, slots = data.slots })
    TriggerEvent('inventory:client:SetCurrentStash', data.name)
end

function nass.inventory.openShop(data)
    --[[
data = {
    identifier = 'shop_identifier',
    name = 'Shop Name',
    inventory = {
        { name = 'item_name', price = 100 },
    },
    locations = {
        vec3(0, 0, 0),
    }
]]
    local shopData = ConvertShopData(data, 'codem-inventory')

    TriggerEvent('codem-inventory:OpenPlayerShop', shopData)
end
