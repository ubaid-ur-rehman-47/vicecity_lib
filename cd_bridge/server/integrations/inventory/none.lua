if Cfg.Inventory ~= 'none' then return end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘


-- Add item to a player's inventory
function Addtem(source, item_name, amount, metadata)
    return true
end

-- Add item to a player's inventory
function RemoveItem(source, item_name, amount, slot)
    return true
end

-- Remove item from a player's inventory
function GetItemCount(source, item_name)
    return 10000
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    return true
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return true
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    return true
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           ITEM METADATA                          │
-- └──────────────────────────────────────────────────────────────────┘

-- Returns the players full inventory
function GetPlayerInventory(source)
    return {}
end

-- Get item information from a specific slot
function GetItemFromSlot(source, slot)
    return nil
end

-- Add quality to an item in a specific slot, or to the first item matching the itemName
function AddQualityToItem(source, slot, qualityIncrease, itemName)

end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)

end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
function SetItemQuality(source, slot, quality, itemName)

end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player can carry a specific item and amount
function GetItemList()
    return {}
end

-- Get inventory images
function GetInventoryImages()
    return {}
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                OTHER                             │
-- └──────────────────────────────────────────────────────────────────┘

function VehiclePlateChangedInventory(oldPlate, newPlate, netId)
    -- This inventory does not support updating vehicle trunk plates, so no action is required here.
end