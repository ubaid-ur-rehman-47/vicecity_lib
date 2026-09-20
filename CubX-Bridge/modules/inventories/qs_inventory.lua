--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local QSInventory = {}

function QSInventory.Initialize()
    if GetResourceState("qs-inventory") ~= "started" then
        CBUX.Utils.Error("qs-inventory not started!")
        return false
    end
    CBUX.Utils.Debug("qs-inventory module initialized")
    return true
end

if IsDuplicityVersion() then
    function QSInventory.AddItem(source, item, amount, slot, info)
        return exports["qs-inventory"]:AddItem(source, item, amount, slot, info)
    end
    
    function QSInventory.RemoveItem(source, item, amount, slot)
        return exports["qs-inventory"]:RemoveItem(source, item, amount, slot)
    end
    
    function QSInventory.GetItem(source, item)
        return exports["qs-inventory"]:GetItemByName(source, item)
    end
    
    function QSInventory.GetItemCount(source, item, metadata)
        return exports["qs-inventory"]:GetItemTotalAmount(source, item) or 0
    end
    
    function QSInventory.HasItem(source, item, amount)
        if not amount then amount = 1 end
        return QSInventory.GetItemCount(source, item) >= amount
    end
    
    function QSInventory.SetItemMetadata(source, slot, metadata)
        return exports["qs-inventory"]:SetItemMetadata(source, slot, metadata)
    end
    
    function QSInventory.GetInventory(source)
        return exports["qs-inventory"]:GetInventory(source)
    end
    
    function QSInventory.GetInventoryItems(source)
        return QSInventory.GetInventory(source)
    end
    
    function QSInventory.CanCarry(source, item, amount)
        return exports["qs-inventory"]:CanCarryItem(source, item, amount)
    end
    
    function QSInventory.GetItemLabel(item)
        local itemData = exports["qs-inventory"]:GetItemList()[item]
        if itemData and itemData.label then
            return itemData.label
        end
        return item
    end
    
    function QSInventory.GetItemWeight(item)
        local itemData = exports["qs-inventory"]:GetItemList()[item]
        if itemData and itemData.weight then
            return itemData.weight
        end
        return 0
    end
    
    function QSInventory.CreateUseableItem(item, cb)
        exports["qs-inventory"]:CreateUsableItem(item, function(source, itemData)
            local player = exports["CubX-Bridge"]:GetPlayer(source)
            cb(source, player, itemData)
        end)
    end
    
    function QSInventory.ClearInventory(source)
        return exports["qs-inventory"]:ClearInventory(source)
    end
    
    function QSInventory.GetSlot(source, slot)
        return exports["qs-inventory"]:GetSlot(source, slot)
    end
    
    function QSInventory.GetItems()
        return exports["qs-inventory"]:GetItemList()
    end
else
    function QSInventory.HasItem(item, amount)
        if not amount then amount = 1 end
        return exports["qs-inventory"]:HasItem(item, amount)
    end
    
    function QSInventory.GetItemCount(item)
        return exports["qs-inventory"]:GetItemTotalAmount(item) or 0
    end
    
    function QSInventory.GetPlayerItems()
        return exports["qs-inventory"]:GetPlayerInventory()
    end
    
    function QSInventory.OpenInventory()
        return exports["qs-inventory"]:OpenInventory()
    end
    
    function QSInventory.CloseInventory()
        return exports["qs-inventory"]:CloseInventory()
    end
end

CBUX.RegisterModule("inventories", "qs-inventory", QSInventory)