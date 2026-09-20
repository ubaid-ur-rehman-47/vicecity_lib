local provider = {
    name = 'esx',
    resource = 'esx_inventory',
    capabilities = { playerItems = true, mutation = true, metadata = false },
}

function provider:getItems()
    local data = ViceCity.Framework.GetPlayerData() or {}
    return ViceCity.Inventory.NormalizeItems(data.inventory, PlayerId())
end

function provider:getItemBySlot(_, slot)
    for _, item in ipairs(self:getItems()) do
        if item.slot == slot then return item end
    end
end

function provider:getRaw()
    local data = ViceCity.Framework.GetPlayerData() or {}
    return data.inventory or {}
end

function provider:open() return false, { reason = 'provider_defined_ui', provider = self.name } end

function provider:close() return true end

ViceCity.RegisterProvider('inventory', 'esx', provider)
