local provider = {
    name = 'native',
    capabilities = {
        playerItems = true,
        metadata = false,
        open = false,
    },
}

function provider:getItems()
    local data = ViceCity.Framework.GetPlayerData()
    return ViceCity.Inventory.NormalizeItems(data and (data.items or data.inventory), PlayerId())
end

function provider:getItemBySlot(_, slot)
    for _, item in ipairs(self:getItems()) do
        if item.slot == slot then return item end
    end
end

function provider:getCapacity()
    local data = ViceCity.Framework.GetPlayerData() or {}
    return { slots = data.slots, maxWeight = data.maxweight }
end

function provider:getRaw()
    local data = ViceCity.Framework.GetPlayerData() or {}
    return data.items or data.inventory or {}
end

function provider:open() return false, { reason = 'unsupported', operation = 'open', provider = self.name } end

function provider:close() return true end

ViceCity.RegisterProvider('inventory', 'native', provider)
