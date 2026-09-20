local provider = {
    name = 'native',
    capabilities = {
        playerItems = true,
        metadata = false,
        mutation = false,
    },
}

function provider:getRaw(source)
    local player = ViceCity.Framework.GetRawPlayer(source)
    local data = player and player.PlayerData
    return data and (data.items or data.inventory) or {}
end

function provider:getItems(source)
    return ViceCity.Inventory.NormalizeItems(self:getRaw(source), source)
end

function provider:getItemBySlot(source, slot)
    for _, item in ipairs(self:getItems(source)) do
        if item.slot == slot then return item end
    end
end

function provider:getCapacity(source)
    local player = ViceCity.Framework.GetRawPlayer(source)
    local data = player and player.PlayerData or {}
    return { slots = data.slots, maxWeight = data.maxweight }
end

function provider:addItem() return false end

function provider:removeItem() return false end

function provider:canCarry() return false end

function provider:registerUsableItem() return false end

ViceCity.RegisterProvider('inventory', 'native', provider)
