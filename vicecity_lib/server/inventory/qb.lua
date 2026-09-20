local function createProvider(name, resource)
    local provider = {
        name = name,
        resource = resource,
        capabilities = {
            playerItems = true,
            mutation = true,
            metadata = true,
            capacity = true,
            stashes = true,
            shops = true,
        },
    }

    local function inventory()
        return exports[provider.resource]
    end

    function provider:getRaw(source)
        local player = ViceCity.Framework.GetRawPlayer(source)
        local data = player and player.PlayerData
        return data and (data.items or data.inventory) or inventory():GetInventory(source)
    end

    function provider:getItems(source)
        local raw = self:getRaw(source)
        return ViceCity.Inventory.NormalizeItems(raw and (raw.items or raw), source)
    end

    function provider:getItemBySlot(source, slot)
        if inventory().GetItemBySlot then
            return ViceCity.Inventory.NormalizeItem(inventory():GetItemBySlot(source, slot), source)
        end
        for _, item in ipairs(self:getItems(source)) do
            if item.slot == slot then return item end
        end
    end

    function provider:addItem(source, item, amount, metadata, slot)
        return inventory():AddItem(source, item, amount, slot or false, metadata) ~= false
    end

    function provider:removeItem(source, item, amount, _, slot)
        return inventory():RemoveItem(source, item, amount, slot or false) ~= false
    end

    function provider:canCarry(source, item, amount)
        if inventory().CanAddItem then return inventory():CanAddItem(source, item, amount) == true end
        return true
    end

    function provider:getCapacity(source)
        local player = ViceCity.Framework.GetRawPlayer(source)
        local data = player and player.PlayerData or {}
        return { slots = data.slots, maxWeight = data.maxweight and data.maxweight / 1000 or nil }
    end

    function provider:getCatalog()
        local catalog = {}
        local framework = ViceCity.Framework.GetRawObject()
        local items = framework and framework.Shared and framework.Shared.Items or {}
        for name, item in pairs(items) do
            catalog[name] = ViceCity.Inventory.NormalizeItem({
                name = name,
                label = item.label,
                weight = item.weight and item.weight / 1000 or 0,
                image = item.image,
                description = item.description,
                type = item.type,
            })
        end
        return catalog
    end

    function provider:registerUsableItem(name, handler)
        local framework = ViceCity.Framework.GetRawObject()
        if not framework or not framework.Functions or not framework.Functions.CreateUseableItem then return false end
        framework.Functions.CreateUseableItem(name, handler)
        return true
    end

    function provider:registerStash(id, options)
        if inventory().CreateInventory then
            return inventory():CreateInventory(id, options or {}) ~= false
        end
        return true
    end

    function provider:getStashItems(id)
        local stash = inventory():GetInventory(id)
        return stash and ViceCity.Inventory.NormalizeItems(stash.items or stash, id) or nil
    end

    function provider:createDrop() return false, { reason = 'unsupported', provider = self.name } end

    function provider:createShop(id, options)
        if inventory().CreateShop then
            return inventory():CreateShop({
                name = id,
                label = options.label,
                items = options
                    .items
            })
        end
        return false, { reason = 'unsupported', provider = self.name }
    end

    function provider:moveStash() return false, { reason = 'unsupported', provider = self.name } end

    return provider
end

ViceCity.RegisterProvider('inventory', 'qb', createProvider('qb', 'qb-inventory'))
ViceCity.RegisterProvider('inventory', 'ps', createProvider('ps', 'ps-inventory'))
ViceCity.RegisterProvider('inventory', 'jpr', createProvider('jpr', 'jpr-inventory'))
ViceCity.RegisterProvider('inventory', 'lj', createProvider('lj', 'lj-inventory'))
