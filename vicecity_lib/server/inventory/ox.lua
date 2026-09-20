local provider = {
    name = 'ox',
    resource = 'ox_inventory',
    capabilities = {
        playerItems = true,
        mutation = true,
        metadata = true,
        capacity = true,
        stashes = true,
        drops = true,
        shops = true,
        durability = true,
    },
}

function provider:getItems(source)
    return ViceCity.Inventory.NormalizeItems(exports.ox_inventory:GetInventoryItems(source), source)
end

function provider:getItemBySlot(source, slot)
    return ViceCity.Inventory.NormalizeItem(exports.ox_inventory:GetSlot(source, slot), source)
end

function provider:getRaw(source)
    return exports.ox_inventory:GetInventory(source, false)
end

function provider:addItem(source, name, amount, metadata, slot)
    return exports.ox_inventory:AddItem(source, name, amount, metadata, slot) ~= false
end

function provider:removeItem(source, name, amount, metadata, slot)
    return exports.ox_inventory:RemoveItem(source, name, amount, metadata, slot) ~= false
end

function provider:canCarry(source, name, amount)
    return exports.ox_inventory:CanCarryItem(source, name, amount) == true
end

function provider:getCapacity(source)
    local inventory = exports.ox_inventory:GetInventory(source, false)
    if type(inventory) ~= 'table' then return nil end
    return { slots = inventory.slots, maxWeight = (inventory.maxWeight or 0) / 1000 }
end

function provider:getCatalog()
    local items, catalog = exports.ox_inventory:Items(), {}
    for name, item in pairs(items or {}) do
        catalog[name] = ViceCity.Inventory.NormalizeItem({
            name = name,
            label = item.label,
            weight = (item.weight or 0) / 1000,
            image = item.client and item.client.image,
            description = item.description,
        })
    end
    return catalog
end

function provider:registerUsableItem() return false, { reason = 'use_handlers_are_item_defined', provider = self.name } end

function provider:registerStash(id, options)
    options = options or {}
    return exports.ox_inventory:RegisterStash(id, options.label or id, options.slots or 50, options.maxWeight or 100000,
        options.owner, options.groups, options.coords) ~= false
end

function provider:getStashItems(id)
    local inventory = exports.ox_inventory:GetInventory(id, false)
    return inventory and ViceCity.Inventory.NormalizeItems(inventory.items, id) or nil
end

function provider:createDrop(prefix, items, coords)
    return exports.ox_inventory:CustomDrop(prefix, items, coords)
end

function provider:createShop(id, options)
    return exports.ox_inventory:RegisterShop(id, options)
end

function provider:moveStash() return false, { reason = 'unsupported', operation = 'moveStash', provider = self.name } end

function provider:setItemMetadata(source, slot, metadata)
    return exports.ox_inventory:SetMetadata(source, slot, metadata) ~= false
end

function provider:setDurability(source, slot, value)
    return exports.ox_inventory:SetDurability(source, slot, value) ~= false
end

ViceCity.RegisterProvider('inventory', 'ox', provider)
