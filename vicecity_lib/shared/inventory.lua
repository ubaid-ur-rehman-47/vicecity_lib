ViceCity.Inventory = ViceCity.Inventory or {}

local function adapter()
    return ViceCity.InventoryAdapter
end

local function call(name, ...)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.GetProvider('inventory') }
    end
    local ok, a, b = pcall(method, provider, ...)
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(a) }
    end
    return a, b
end

local function matches(value, required)
    if type(required) ~= 'table' then return value == required end
    if type(value) ~= 'table' then return false end
    for key, expected in pairs(required) do
        if not matches(value[key], expected) then return false end
    end
    return true
end

function ViceCity.Inventory.NormalizeItem(item, source)
    if type(item) ~= 'table' then return nil end
    local metadata = item.metadata or item.info or {}
    local count = item.count or item.amount or item.quantity or 0
    local image = item.image or item.img
    return {
        name = item.name or item.item,
        label = item.label or item.name or item.item,
        count = tonumber(count) or 0,
        slot = item.slot,
        metadata = metadata,
        weight = tonumber(item.weight) or 0,
        image = image,
        imageUrl = item.imageUrl,
        description = item.description,
        type = item.type,
        usable = item.usable == true,
        weapon = item.weapon == true or item.type == 'weapon',
        ammo = item.ammo,
        serial = item.serial or metadata.serial,
        durability = item.durability or metadata.durability,
        source = source,
        raw = item,
    }
end

function ViceCity.Inventory.NormalizeItems(items, source)
    local normalized = {}
    for _, item in pairs(items or {}) do
        local value = ViceCity.Inventory.NormalizeItem(item, source)
        if value and value.name then normalized[#normalized + 1] = value end
    end
    return normalized
end

function ViceCity.Inventory.GetName()
    return ViceCity.GetProvider('inventory')
end

function ViceCity.Inventory.GetCapabilities()
    local provider = adapter()
    return provider and provider.capabilities or {}
end

function ViceCity.Inventory.GetItems(source)
    return call('getItems', source)
end

function ViceCity.Inventory.GetItem(source, name, metadata)
    local items = ViceCity.Inventory.GetItems(source)
    if type(items) ~= 'table' then return nil end
    for _, item in pairs(items) do
        if item.name == name and (metadata == nil or matches(item.metadata, metadata)) then return item end
    end
end

function ViceCity.Inventory.GetItemBySlot(source, slot)
    return call('getItemBySlot', source, slot)
end

function ViceCity.Inventory.GetItemCount(source, name, metadata)
    local item = ViceCity.Inventory.GetItem(source, name, metadata)
    return item and tonumber(item.count) or 0
end

function ViceCity.Inventory.HasItem(source, name, amount, metadata)
    return ViceCity.Inventory.GetItemCount(source, name, metadata) >= (amount or 1)
end

function ViceCity.Inventory.AddItem(source, name, amount, metadata, slot)
    return call('addItem', source, name, amount, metadata, slot)
end

function ViceCity.Inventory.RemoveItem(source, name, amount, metadata, slot)
    return call('removeItem', source, name, amount, metadata, slot)
end

function ViceCity.Inventory.CanCarry(source, name, amount, metadata)
    return call('canCarry', source, name, amount, metadata)
end

function ViceCity.Inventory.GetCapacity(source)
    return call('getCapacity', source)
end

function ViceCity.Inventory.GetCatalog()
    return call('getCatalog')
end

function ViceCity.Inventory.GetItemImage(item)
    return item and (item.imageUrl or item.image) or nil
end

function ViceCity.Inventory.GetRaw(source)
    return call('getRaw', source)
end

function ViceCity.Inventory.RegisterUsableItem(name, handler)
    return call('registerUsableItem', name, handler)
end

function ViceCity.Inventory.RegisterStash(id, options)
    return call('registerStash', id, options)
end

function ViceCity.Inventory.GetStashItems(id)
    return call('getStashItems', id)
end

function ViceCity.Inventory.CreateDrop(prefix, items, coords)
    return call('createDrop', prefix, items, coords)
end

function ViceCity.Inventory.CreateShop(id, options)
    return call('createShop', id, options)
end

function ViceCity.Inventory.MoveStash(fromId, toId)
    return call('moveStash', fromId, toId)
end

function ViceCity.Inventory.SetItemMetadata(source, slot, metadata)
    return call('setItemMetadata', source, slot, metadata)
end

function ViceCity.Inventory.SetDurability(source, slot, value)
    return call('setDurability', source, slot, value)
end

function ViceCity.Inventory.Open(type, data)
    return call('open', type, data)
end

function ViceCity.Inventory.Close()
    return call('close')
end

GetInventory = ViceCity.Inventory
