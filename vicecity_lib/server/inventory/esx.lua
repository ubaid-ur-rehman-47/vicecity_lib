local provider = {
    name = 'esx',
    resource = 'esx_inventory',
    capabilities = { playerItems = true, mutation = true, metadata = false },
}

function provider:getRaw(source)
    local player = ViceCity.Framework.GetRawPlayer(source)
    return player and player.getInventory and player.getInventory() or {}
end

function provider:getItems(source)
    return ViceCity.Inventory.NormalizeItems(self:getRaw(source), source)
end

function provider:getItemBySlot(source)
    return nil
end

function provider:addItem(source, item, amount)
    local player = ViceCity.Framework.GetRawPlayer(source)
    if not player or not player.addInventoryItem then return false end
    player.addInventoryItem(item, amount)
    return true
end

function provider:removeItem(source, item, amount)
    local player = ViceCity.Framework.GetRawPlayer(source)
    if not player or not player.removeInventoryItem then return false end
    player.removeInventoryItem(item, amount)
    return true
end

function provider:canCarry(source, item, amount)
    local player = ViceCity.Framework.GetRawPlayer(source)
    return player and player.canCarryItem and player.canCarryItem(item, amount) or false
end

function provider:getCapacity(source)
    local player = ViceCity.Framework.GetRawPlayer(source)
    return player and player.getMaxWeight and { maxWeight = player.getMaxWeight() } or nil
end

ViceCity.RegisterProvider('inventory', 'esx', provider)
