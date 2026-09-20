function ViceCityCreateClientInventoryProvider(name, resource, openMethod)
    local provider = {
        name = name,
        resource = resource,
        capabilities = { playerItems = true, open = openMethod ~= nil },
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

    function provider:getRaw()
        local data = ViceCity.Framework.GetPlayerData() or {}
        return data.items or data.inventory or {}
    end

    function provider:open(inventoryType, data)
        if not openMethod then return false, { reason = 'unsupported', operation = 'open', provider = name } end
        local ok, result = pcall(function()
            return exports[resource][openMethod](inventoryType, data)
        end)
        return ok and result ~= false or false
    end

    function provider:close()
        local ok = pcall(function() exports[resource]:CloseInventory() end)
        return ok
    end

    ViceCity.RegisterProvider('inventory', name, provider)
end
