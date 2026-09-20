--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local OxInventory = {}
local OxInv = nil

function OxInventory.Initialize()
    if GetResourceState("ox_inventory") ~= "started" then
        CBUX.Utils.Error("ox_inventory not started!")
        return false
    end
    OxInv = exports.ox_inventory
    CBUX.Utils.Debug("ox_inventory module initialized")
    return true
end

if IsDuplicityVersion() then
    function OxInventory.AddItem(source, item, amount, metadata, slot)
        return OxInv:AddItem(source, item, amount, metadata, slot)
    end
    
    function OxInventory.RemoveItem(source, item, amount, metadata, slot)
        return OxInv:RemoveItem(source, item, amount, metadata, slot)
    end
    
    function OxInventory.GetItem(source, item, metadata, returnCount)
        return OxInv:GetItem(source, item, metadata, returnCount)
    end
    
    function OxInventory.GetItemCount(source, item, metadata)
        return OxInv:GetItemCount(source, item, metadata) or 0
    end
    
    function OxInventory.HasItem(source, item, amount)
        if not amount then amount = 1 end
        return OxInventory.GetItemCount(source, item) >= amount
    end
    
    function OxInventory.SetItemMetadata(source, slot, metadata)
        return OxInv:SetMetadata(source, slot, metadata)
    end
    
    function OxInventory.GetInventory(source)
        return OxInv:GetInventory(source)
    end
    
    function OxInventory.GetInventoryItems(source)
        return OxInv:GetInventoryItems(source)
    end
    
    function OxInventory.CanCarry(source, item, amount)
        return OxInv:CanCarryItem(source, item, amount)
    end
    
    function OxInventory.GetItemLabel(item)
        local itemData = OxInv:Items(item)
        if itemData and itemData.label then
            return itemData.label
        end
        return item
    end
    
    function OxInventory.GetItemWeight(item)
        local itemData = OxInv:Items(item)
        if itemData and itemData.weight then
            return itemData.weight
        end
        return 0
    end
    
    function OxInventory.CreateUseableItem(item, cb)
        CBUX.Utils.Debug("ox_inventory uses item definitions for useable items")
    end
    
    function OxInventory.ClearInventory(source)
        return OxInv:ClearInventory(source)
    end
    
    function OxInventory.GetSlot(source, slot)
        return OxInv:GetSlot(source, slot)
    end
    
    function OxInventory.GetSlots(source)
        return OxInv:GetSlots(source)
    end
    
    function OxInventory.SetSlotCount(source, slots)
        return OxInv:SetSlotCount(source, slots)
    end
    
    function OxInventory.SetMaxWeight(source, maxWeight)
        return OxInv:SetMaxWeight(source, maxWeight)
    end
    
    function OxInventory.GetItems()
        return OxInv:Items()
    end
else
    function OxInventory.HasItem(item, amount)
        if not amount then amount = 1 end
        return OxInv:GetItemCount(item) >= amount
    end
    
    function OxInventory.GetItemCount(item)
        return OxInv:GetItemCount(item) or 0
    end
    
    function OxInventory.GetPlayerItems()
        return OxInv:GetPlayerItems()
    end
    
    function OxInventory.GetPlayerWeight()
        return OxInv:GetPlayerWeight()
    end
    
    function OxInventory.GetPlayerMaxWeight()
        return OxInv:GetPlayerMaxWeight()
    end
    
    function OxInventory.UseItem(item)
        return OxInv:useItem(item)
    end
    
    function OxInventory.OpenInventory(invType, data)
        return OxInv:openInventory(invType, data)
    end
    
    function OxInventory.CloseInventory()
        return OxInv:closeInventory()
    end
end

CBUX.RegisterModule("inventories", "ox_inventory", OxInventory)