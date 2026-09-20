if Cfg.Inventory ~= 'other' then return end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to add.
--- @param amount      number   The amount to add.
--- @param metadata    table    Additional item metadata (optional).
--- @return boolean #           True if the item was added successfully, false otherwise.
function AddItem(source, item_name, amount, metadata)
    return true
end

-- Remove item from a player's inventory
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to remove.
--- @param amount      number   The amount remove.
--- @param slot        number   The inventory slot id (optional, only used if the inventory supports item quality or if you want to specify which item to remove).
--- @return boolean #           True if the item was removed successfully, false otherwise.
function RemoveItem(source, item_name, amount, slot)
    return true
end

-- Check if a player has a specific item and amount
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param amount      number   The required amount.
--- @return boolean    --True if the player has at least `amount` of `item_name`, false otherwise.
function HasItem(source, item_name, amount)
    amount = amount or 1
    return true
end

-- Get the count of a specific item in a player's inventory
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @return number              --The amount of `item_name` the player has.
function GetItemCount(source, item_name)
    return 0
end

-- Check if a player can carry a specific item and amount
--- @param source      number   The player's server ID.
--- @param item_name   string   The item to check for.
--- @param amount      number   The amount to check for.
--- @return boolean             --True if the player can carry `amount` of `item_name`, false otherwise.
function CanCarryItem(source, item_name, amount)
    return true
end

-- Add weapon to a player's inventory
--- @param source      number   The player's server ID.
--- @param weapon_name string   The weapon to add.
--- @param ammo        number   The amount of ammo to add.
--- @return boolean             --True if the weapon was added successfully, false otherwise.
function AddWeapon(source, weapon_name, ammo)
    return true
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           ITEM METADATA                          │
-- └──────────────────────────────────────────────────────────────────┘

-- Returns the players full inventory
--- @param source number The player's server ID.
--- @return table # The player's inventory.
function GetPlayerInventory(source)
    return {}
end

-- Get item information from a specific slot
--- @param source number The player's server ID.
--- @param slot number The inventory slot id.
--- @return table|nil # The item information, or nil if no item was found in the specified slot.
function GetItemFromSlot(source, slot)
    return {}
end

-- Add quality to an item in a specific slot, or to the first item matching the itemName
--- @param source number The player's server ID.
--- @param item_name string The item name.
--- @param qualityIncrease number The amount of quality to add.
--- @param slot number|nil The inventory slot id.
function AddQualityToItem(source, slot, qualityIncrease, itemName)

end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
--- @param source number The player's server ID.
--- @param item_name string The item name.
--- @param qualityDecrease number The amount of quality to remove.
--- @--- @param slot number|nil The item slot to add quality to.
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)

end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
--- @param source number The player's server ID.
--- @param item_name string The item name.
--- @param quality number The quality to set.
--- @--- @param slot number|nil The inventory slot id.
function SetItemQuality(source, slot, quality, itemName)

end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player can carry a specific item and amount
--- @return table   --A table of all items in the inventory system.
---                 The returned table must follow this structure:
---                 items['item_label'] = {
---                     name  = 'item_name',
---                     label = 'item_label'
---                 }
function GetItemList()
    return {}
end

-- Get inventory images
--- @return table   --A table of all inventory item images.
---                 The returned table must follow this structure:
---                 images[1] = 'water.png'
function GetInventoryImages()
    return {}
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                OTHER                             │
-- └──────────────────────────────────────────────────────────────────┘

--- comment
--- @param oldPlate string The vehicle's old plate.
--- @param newPlate string The vehicle's new plate.
--- @param netId number | nil The vehicle's network ID, sometimes it might be nil.
function VehiclePlateChangedInventory(oldPlate, newPlate, netId)
end