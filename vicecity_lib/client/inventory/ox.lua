local provider = {
    name = 'ox',
    resource = 'ox_inventory',
    capabilities = {
        playerItems = true,
        metadata = true,
        capacity = true,
        open = true,
    },
}

function provider:getItems()
    local items = exports.ox_inventory:GetPlayerItems()
    return ViceCity.Inventory.NormalizeItems(items, PlayerId())
end

function provider:getItemBySlot(_, slot)
    local item = exports.ox_inventory:GetSlot(slot)
    return ViceCity.Inventory.NormalizeItem(item, PlayerId())
end

function provider:getCapacity()
    local inventory = exports.ox_inventory:GetPlayerInventory()
    if not inventory then return nil end
    return {
        slots = inventory.slots,
        maxWeight = (tonumber(inventory.maxWeight) or 0) / 1000,
    }
end

function provider:getRaw()
    return exports.ox_inventory:GetPlayerItems()
end

function provider:open(inventoryType, data)
    return exports.ox_inventory:openInventory(inventoryType, data)
end

function provider:close()
    return exports.ox_inventory:closeInventory()
end

ViceCity.RegisterProvider('inventory', 'ox', provider)
