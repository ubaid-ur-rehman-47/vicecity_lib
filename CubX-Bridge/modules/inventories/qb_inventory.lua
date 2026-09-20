--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local QBInventory = {}

function QBInventory.Initialize()
    if GetResourceState("qb-inventory") ~= "started" then
        CBUX.Utils.Error("qb-inventory not started!")
        return false
    end
    CBUX.Utils.Debug("qb-inventory module initialized")
    return true
end

if IsDuplicityVersion() then
    function QBInventory.AddItem(source, item, amount, slot, info)
        local player = exports["CubX-Bridge"]:GetPlayer(source)
        if not player or not player._qbPlayer then return false end
        return player._qbPlayer.Functions.AddItem(item, amount, slot, info)
    end
    
    function QBInventory.RemoveItem(source, item, amount, slot)
        local player = exports["CubX-Bridge"]:GetPlayer(source)
        if not player or not player._qbPlayer then return false end
        return player._qbPlayer.Functions.RemoveItem(item, amount, slot)
    end
    
    function QBInventory.GetItem(source, item)
        local player = exports["CubX-Bridge"]:GetPlayer(source)
        if not player or not player._qbPlayer then return nil end
        return player._qbPlayer.Functions.GetItemByName(item)
    end
    
    function QBInventory.GetItemCount(source, item, metadata)
        local itemData = QBInventory.GetItem(source, item, metadata)
        if itemData and itemData.amount then
            return itemData.amount
        end
        return 0
    end
    
    function QBInventory.HasItem(source, item, amount)
        if not amount then amount = 1 end
        local player = exports["CubX-Bridge"]:GetPlayer(source)
        if not player or not player._qbPlayer then return false end
        return player._qbPlayer.Functions.HasItem(item, amount)
    end
    
    function QBInventory.SetItemMetadata(source, slot, metadata)
        CBUX.Utils.Warn("SetItemMetadata not directly supported in qb-inventory")
        return false
    end
    
    function QBInventory.GetInventory(source)
        local player = exports["CubX-Bridge"]:GetPlayer(source)
        if not player or not player._qbPlayer then return {} end
        return player._qbPlayer.PlayerData.items or {}
    end
    
    function QBInventory.GetInventoryItems(source)
        return QBInventory.GetInventory(source)
    end
    
    function QBInventory.CanCarry(source, item, amount)
        return true
    end
    
    function QBInventory.GetItemLabel(item)
        if CBUX.FrameworkObject and CBUX.FrameworkObject.Shared and CBUX.FrameworkObject.Shared.Items then
            local itemData = CBUX.FrameworkObject.Shared.Items[item]
            if itemData and itemData.label then
                return itemData.label
            end
        end
        return item
    end
    
    function QBInventory.GetItemWeight(item)
        if CBUX.FrameworkObject and CBUX.FrameworkObject.Shared and CBUX.FrameworkObject.Shared.Items then
            local itemData = CBUX.FrameworkObject.Shared.Items[item]
            if itemData and itemData.weight then
                return itemData.weight
            end
        end
        return 0
    end
    
    function QBInventory.CreateUseableItem(item, cb)
        if CBUX.FrameworkObject then
            CBUX.FrameworkObject.Functions.CreateUseableItem(item, function(source, itemData)
                local player = exports["CubX-Bridge"]:GetPlayer(source)
                cb(source, player, itemData)
            end)
        end
    end
    
    function QBInventory.ClearInventory(source)
        local player = exports["CubX-Bridge"]:GetPlayer(source)
        if not player or not player._qbPlayer then return false end
        player._qbPlayer.PlayerData.items = {}
        player._qbPlayer.Functions.UpdatePlayerData()
        return true
    end
    
    function QBInventory.GetSlot(source, slot)
        local inventory = QBInventory.GetInventory(source)
        return inventory[slot]
    end
    
    function QBInventory.GetItems()
        if CBUX.FrameworkObject and CBUX.FrameworkObject.Shared then
            return CBUX.FrameworkObject.Shared.Items or {}
        end
        return {}
    end
else
    function QBInventory.HasItem(item, amount)
        if not amount then amount = 1 end
        if CBUX.FrameworkObject then
            return CBUX.FrameworkObject.Functions.HasItem(item, amount)
        end
        return false
    end
    
    function QBInventory.GetItemCount(item)
        if CBUX.FrameworkObject then
            local itemData = CBUX.FrameworkObject.Functions.GetItemByName(item)
            if itemData and itemData.amount then
                return itemData.amount
            end
        end
        return 0
    end
    
    function QBInventory.GetPlayerItems()
        local pData = exports["CubX-Bridge"]:GetPlayerData()
        if pData and pData.items then
            return pData.items
        end
        return {}
    end
end

CBUX.RegisterModule("inventories", "qb-inventory", QBInventory)