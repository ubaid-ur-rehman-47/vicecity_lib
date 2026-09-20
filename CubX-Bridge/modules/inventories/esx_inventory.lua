--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local ESXInventory = {}

function ESXInventory.Initialize()
    if GetResourceState("es_extended") ~= "started" then
        CBUX.Utils.Error("es_extended not started!")
        return false
    end
    CBUX.Utils.Debug("esx_inventory module initialized")
    return true
end

if IsDuplicityVersion() then
    function ESXInventory.AddItem(source, item, amount, slot, info)
        local xPlayer = CBUX.FrameworkObject.GetPlayerFromId(source)
        if not xPlayer then return false end
        xPlayer.addInventoryItem(item, amount)
        return true
    end
    
    function ESXInventory.RemoveItem(source, item, amount, slot, info)
        local xPlayer = CBUX.FrameworkObject.GetPlayerFromId(source)
        if not xPlayer then return false end
        local itemData = xPlayer.getInventoryItem(item)
        if itemData and itemData.count >= amount then
            xPlayer.removeInventoryItem(item, amount)
            return true
        end
        return false
    end
    
    function ESXInventory.GetItem(source, item)
        local xPlayer = CBUX.FrameworkObject.GetPlayerFromId(source)
        if not xPlayer then return nil end
        return xPlayer.getInventoryItem(item)
    end
    
    function ESXInventory.GetItemCount(source, item, metadata)
        local itemData = ESXInventory.GetItem(source, item, metadata)
        if itemData and itemData.count then
            return itemData.count
        end
        return 0
    end
    
    function ESXInventory.HasItem(source, item, amount)
        if not amount then amount = 1 end
        return ESXInventory.GetItemCount(source, item) >= amount
    end
    
    function ESXInventory.SetItemMetadata(source, slot, metadata)
        CBUX.Utils.Warn("SetItemMetadata not supported in ESX native inventory")
        return false
    end
    
    function ESXInventory.GetInventory(source)
        local xPlayer = CBUX.FrameworkObject.GetPlayerFromId(source)
        if not xPlayer then return {} end
        return xPlayer.getInventory()
    end
    
    function ESXInventory.GetInventoryItems(source)
        return ESXInventory.GetInventory(source)
    end
    
    function ESXInventory.CanCarry(source, item, amount)
        local xPlayer = CBUX.FrameworkObject.GetPlayerFromId(source)
        if not xPlayer then return false end
        return xPlayer.canCarryItem(item, amount)
    end
    
    function ESXInventory.GetItemLabel(item)
        local label = CBUX.FrameworkObject.GetItemLabel(item)
        return label or item
    end
    
    function ESXInventory.GetItemWeight(item)
        local items = CBUX.FrameworkObject.GetItems()
        if items and items[item] then
            return items[item].weight or 0
        end
        return 0
    end
    
    function ESXInventory.CreateUseableItem(item, cb)
        CBUX.FrameworkObject.RegisterUsableItem(item, function(source)
            local player = exports["CubX-Bridge"]:GetPlayer(source)
            local itemData = ESXInventory.GetItem(source, item)
            cb(source, player, itemData)
        end)
    end
    
    function ESXInventory.ClearInventory(source)
        local inventory = ESXInventory.GetInventory(source)
        for _, itemData in pairs(inventory) do
            if itemData.count > 0 then
                ESXInventory.RemoveItem(source, itemData.name, itemData.count)
            end
        end
        return true
    end
    
    function ESXInventory.GetItems()
        return CBUX.FrameworkObject.GetItems()
    end
else
    function ESXInventory.HasItem(item, amount)
        if not amount then amount = 1 end
        local pData = CBUX.FrameworkObject.GetPlayerData()
        if pData and pData.inventory then
            for _, itemData in pairs(pData.inventory) do
                if itemData.name == item then
                    return itemData.count >= amount
                end
            end
        end
        return false
    end
    
    function ESXInventory.GetItemCount(item)
        local pData = CBUX.FrameworkObject.GetPlayerData()
        if pData and pData.inventory then
            for _, itemData in pairs(pData.inventory) do
                if itemData.name == item then
                    return itemData.count or 0
                end
            end
        end
        return 0
    end
    
    function ESXInventory.GetPlayerItems()
        local pData = CBUX.FrameworkObject.GetPlayerData()
        if pData and pData.inventory then
            return pData.inventory
        end
        return {}
    end
end

CBUX.RegisterModule("inventories", "esx_inventory", ESXInventory)