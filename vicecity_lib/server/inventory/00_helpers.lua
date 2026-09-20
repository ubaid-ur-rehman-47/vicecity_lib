local function invoke(resource, method, ...)
    if not method then return nil end
    local arguments = { ... }
    local ok, first, second = pcall(function()
        return exports[resource][method](table.unpack(arguments))
    end)
    if not ok then return nil end
    return first, second
end

function ViceCityCreateInventoryProvider(name, resource, spec)
    local provider = {
        name = name,
        resource = resource,
        capabilities = {
            playerItems = spec.items ~= nil,
            mutation = spec.add ~= nil and spec.remove ~= nil,
            metadata = spec.metadata ~= nil,
            capacity = false,
            stashes = false,
            shops = false,
        },
    }

    function provider:getRaw(source)
        return invoke(resource, spec.items, source)
    end

    function provider:getItems(source)
        local raw = self:getRaw(source)
        if type(raw) ~= 'table' then return {} end
        return ViceCity.Inventory.NormalizeItems(raw.items or raw, source)
    end

    function provider:getItemBySlot(source, slot)
        local item = invoke(resource, spec.slot, source, slot)
        if item then return ViceCity.Inventory.NormalizeItem(item, source) end
        for _, value in ipairs(self:getItems(source)) do
            if value.slot == slot then return value end
        end
    end

    function provider:addItem(source, item, amount, metadata, slot)
        local result = invoke(resource, spec.add, source, item, amount, slot, metadata)
        return result ~= false and result ~= nil
    end

    function provider:removeItem(source, item, amount, metadata, slot)
        local result = invoke(resource, spec.remove, source, item, amount, slot, metadata)
        return result ~= false and result ~= nil
    end

    function provider:canCarry(source, item, amount)
        if not spec.carry then return true end
        return invoke(resource, spec.carry, source, item, amount) == true
    end

    function provider:getItemCount(source, item)
        return tonumber(invoke(resource, spec.count, source, item)) or 0
    end

    function provider:getCatalog()
        local raw = invoke(resource, spec.catalog)
        local catalog = {}
        for nameValue, item in pairs(raw or {}) do
            if type(item) == 'table' then
                item.name = item.name or nameValue
                catalog[item.name] = ViceCity.Inventory.NormalizeItem(item)
            end
        end
        return catalog
    end

    function provider:setItemMetadata(source, slot, metadata)
        return invoke(resource, spec.metadata, source, slot, metadata) ~= false
    end

    function provider:setDurability(source, slot, value)
        return invoke(resource, spec.durability, source, slot, value) ~= false
    end

    function provider:createDrop(prefix, items, coords)
        return invoke(resource, spec.drop, prefix, items, coords)
    end

    ViceCity.RegisterProvider('inventory', name, provider)
end
