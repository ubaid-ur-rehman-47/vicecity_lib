--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

function GetInventorySystemFn(funcName)
    if CBUX.Modules.Inventory then
        if CBUX.Modules.Inventory[funcName] then
            return CBUX.Modules.Inventory[funcName]
        end
    end
    if CBUX.Modules.Framework then
        if CBUX.Modules.Framework[funcName] then
            return CBUX.Modules.Framework[funcName]
        end
    end
    return nil
end

function HasItem(item, amount)
    if not CBUX.Ready then
        return false
    end
    if not amount then
        amount = 1
    end
    local fn = GetInventorySystemFn("HasItem")
    if fn then
        return fn(item, amount)
    end
    return false
end

function GetItemCount(item)
    if not CBUX.Ready then
        return 0
    end
    local fn = GetInventorySystemFn("GetItemCount")
    if fn then
        return fn(item)
    end
    return 0
end

function GetPlayerItems()
    if not CBUX.Ready then
        return {}
    end
    local fn = GetInventorySystemFn("GetPlayerItems")
    if fn then
        return fn()
    end
    return {}
end

function GetPlayerWeight()
    if not CBUX.Ready then
        return 0
    end
    local fn = GetInventorySystemFn("GetPlayerWeight")
    if fn then
        return fn()
    end
    return 0
end

function GetPlayerMaxWeight()
    if not CBUX.Ready then
        return 0
    end
    local fn = GetInventorySystemFn("GetPlayerMaxWeight")
    if fn then
        return fn()
    end
    return 0
end

function OpenInventory(inventoryType, data)
    if not CBUX.Ready then
        return
    end
    local fn = GetInventorySystemFn("OpenInventory")
    if fn then
        return fn(inventoryType, data)
    end
    CBUX.Utils.Warn("OpenInventory: Not supported by current inventory")
end

function CloseInventory()
    if not CBUX.Ready then
        return
    end
    local fn = GetInventorySystemFn("CloseInventory")
    if fn then
        return fn()
    end
end

RegisterNetEvent(Config.EventPrefix .. ":client:itemAdded", function(item, amount)
    TriggerEvent(Config.EventPrefix .. ":client:itemAdded", item, amount)
end)

RegisterNetEvent(Config.EventPrefix .. ":client:itemRemoved", function(item, amount)
    TriggerEvent(Config.EventPrefix .. ":client:itemRemoved", item, amount)
end)

exports("HasItem", HasItem)
exports("GetItemCount", GetItemCount)
exports("GetPlayerItems", GetPlayerItems)
exports("GetPlayerWeight", GetPlayerWeight)
exports("GetPlayerMaxWeight", GetPlayerMaxWeight)
exports("OpenInventory", OpenInventory)
exports("CloseInventory", CloseInventory)