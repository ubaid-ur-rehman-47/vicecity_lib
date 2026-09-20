local function createProvider(name, resource)
    local provider = {
        name = name,
        resource = resource,
        capabilities = {
            playerItems = true,
            metadata = true,
            capacity = true,
            open = true,
        },
    }

    function provider:getItems()
        local data = ViceCity.Framework.GetPlayerData() or {}
        return ViceCity.Inventory.NormalizeItems(data.items or data.inventory, PlayerId())
    end

    function provider:getItemBySlot(_, slot)
        for _, item in ipairs(self:getItems()) do
            if item.slot == slot then return item end
        end
    end

    function provider:getCapacity()
        local data = ViceCity.Framework.GetPlayerData() or {}
        return {
            slots = data.slots,
            maxWeight = data.maxweight and data.maxweight / 1000 or nil,
        }
    end

    function provider:getRaw()
        local data = ViceCity.Framework.GetPlayerData() or {}
        return data.items or data.inventory or {}
    end

    function provider:open(inventoryType, data)
        if inventoryType == 'shop' then
            return exports[self.resource]:OpenShop(data and (data.type or data.name))
        end
        if inventoryType == 'player' then
            return exports[self.resource]:OpenInventoryById(data)
        end
        return exports[self.resource]:OpenInventory(data and (data.id or data.name or data.stashId), data)
    end

    function provider:close()
        if exports[self.resource].CloseInventory then
            return exports[self.resource]:CloseInventory()
        end
        return true
    end

    return provider
end

ViceCity.RegisterProvider('inventory', 'qb', createProvider('qb', 'qb-inventory'))
ViceCity.RegisterProvider('inventory', 'ps', createProvider('ps', 'ps-inventory'))
ViceCity.RegisterProvider('inventory', 'jpr', createProvider('jpr', 'jpr-inventory'))
ViceCity.RegisterProvider('inventory', 'lj', createProvider('lj', 'lj-inventory'))
