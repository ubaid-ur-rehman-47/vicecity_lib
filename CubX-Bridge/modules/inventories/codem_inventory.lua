--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local CodemInventory = {}

function CodemInventory.Initialize()
    if GetResourceState("codem-inventory") ~= "started" then
        CBUX.Utils.Error("codem-inventory not started!")
        return false
    end
    CBUX.Utils.Debug("codem-inventory module initialized")
    return true
end

if IsDuplicityVersion() then
    function CodemInventory.AddItem(source, item, amount, slot, info)
        return exports["codem-inventory"]:AddItem(source, item, amount, slot, info)
    end
    
    function CodemInventory.RemoveItem(source, item, amount, slot)
        return exports["codem-inventory"]:RemoveItem(source, item, amount, slot)
    end
    
    function CodemInventory.GetItem(source, item)
        return exports["codem-inventory"]:GetItemByName(source, item)
    end
    
    function CodemInventory.GetItemCount(source, item, metadata)
        local itemData = CodemInventory.GetItem(source, item, metadata)
        if type(itemData) == "table" then
            return itemData.amount or itemData.count or 0
        end
        return 0
    end
    
    function CodemInventory.HasItem(source, item, amount)
        if not amount then amount = 1 end
        return CodemInventory.GetItemCount(source, item) >= amount
    end
    
    function CodemInventory.SetItemMetadata(source, slot, metadata)
        return exports["codem-inventory"]:SetItemMetadata(source, slot, metadata)
    end
    
    function CodemInventory.GetInventory(source)
        return exports["codem-inventory"]:GetInventory(source)
    end
    
    function CodemInventory.GetInventoryItems(source)
        return CodemInventory.GetInventory(source)
    end
    
    function CodemInventory.CanCarry(source, item, amount)
        return exports["codem-inventory"]:CanCarryItem(source, item, amount) ~= false
    end
    
    function CodemInventory.GetItemLabel(item)
        local itemData = exports["codem-inventory"]:GetItemData(item)
        if itemData and itemData.label then
            return itemData.label
        end
        return item
    end
    
    function CodemInventory.GetItemWeight(item)
        local itemData = exports["codem-inventory"]:GetItemData(item)
        if itemData and itemData.weight then
            return itemData.weight
        end
        return 0
    end
    
    function CodemInventory.CreateUseableItem(item, cb)
        exports["codem-inventory"]:CreateUsableItem(item, function(source, itemData)
            local player = exports["CubX-Bridge"]:GetPlayer(source)
            cb(source, player, itemData)
        end)
    end
    
    function CodemInventory.ClearInventory(source)
        return exports["codem-inventory"]:ClearInventory(source)
    end
    
    function CodemInventory.GetSlot(source, slot)
        return exports["codem-inventory"]:GetSlot(source, slot)
    end
    
    function CodemInventory.GetItems()
        return exports["codem-inventory"]:GetItems()
    end
else
    function CodemInventory.HasItem(item, amount)
        if not amount then amount = 1 end
        return exports["codem-inventory"]:HasItem(item, amount)
    end
    
    function CodemInventory.GetItemCount(item)
        local itemData = exports["codem-inventory"]:GetItemByName(item)
        if type(itemData) == "table" then
            return itemData.amount or itemData.count or 0
        end
        return 0
    end
    
    function CodemInventory.GetPlayerItems()
        return exports["codem-inventory"]:GetPlayerInventory()
    end
    
    function CodemInventory.OpenInventory()
        return exports["codem-inventory"]:OpenInventory()
    end
    
    function CodemInventory.CloseInventory()
        return exports["codem-inventory"]:CloseInventory()
    end
end

CBUX.RegisterModule("inventories", "codem-inventory", CodemInventory)