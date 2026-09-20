local found = GetResourceState('qs-inventory')
if found ~= 'started' and found ~= 'starting' then return end

nass.inventorySystem = 'qs-inventory'
nass.inventory = {}

function nass.inventory.openPlayerInventory(targetId)
    TriggerServerEvent('inventory:server:OpenInventory', 'otherplayer', targetId)
    TriggerEvent('inventory:server:RobPlayer', targetId)
end

function nass.inventory.openStash(data)
    -- data = {name = name, unique = true, maxWeight = maxWeight, slots = slots}
    if data.unique then
        data.name = ('%s_%s'):format(data.name, nass.getIdentifier())
    end

    TriggerServerEvent('inventory:server:OpenInventory', 'stash', data.name)

    --TriggerServerEvent('inventory:server:OpenInventory', 'stash', data.name,
    --    { maxweight = data.maxWeight, slots = data.slots })
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
}
]]
    local shopData = ConvertShopData(data)

    TriggerServerEvent("inventory:server:OpenInventory", "shop", data.name, shopData)
end