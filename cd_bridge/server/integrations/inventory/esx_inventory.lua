if Cfg.Inventory ~= 'esx_inventory' then return end

local ItemList = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
function AddItem(source, item_name, amount, metadata)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.addInventoryItem(item_name, amount)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount, slot)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.removeInventoryItem(item_name, amount)
end

-- Remove item from a player's inventory with matching metadata
function RemoveItemWithMetadata(source, item_name, amount, metadata)
    return RemoveItem(source, item_name, amount, metadata)
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    amount = amount or 1
    return Player.hasItem(item_name)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local Player = GetPlayer(source)
    if not Player then return 0 end

    local hasItem, count = Player.hasItem(item_name)
    if hasItem and count then
        return count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.canCarryItem(item_name, amount)
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    local Player = GetPlayer(source)
    if not Player then return false end

    return Player.addWeapon(weapon_name, ammo)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           ITEM METADATA                          │
-- └──────────────────────────────────────────────────────────────────┘

-- Returns the players full inventory
function GetPlayerInventory(source)
    local Player = GetPlayer(source)
    if not Player then return {} end

    local inventory = Player.getInventory()
    if not inventory then return {} end

    local normalisedInventory = {}
    for _, item in pairs(inventory) do
        table.insert(normalisedInventory, {
            name = item.name,
            label = item.label,
            amount = item.count
        })
    end
    return normalisedInventory
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

-- Get the list of all items in the database
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end

    local items = DB.fetch('SELECT name, label FROM items')
    if not items then
        return ItemList
    end

    for k, v in pairs(items) do
        local name = type(k) == 'string' and k or v.name

        if name then
            ItemList[name] = {
                name = name,
                label = v.label or name,
            }
        end
    end

    return ItemList
end

-- Get inventory images (not supported in ESX Inventory)
function GetInventoryImages()
    return {}
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                OTHER                             │
-- └──────────────────────────────────────────────────────────────────┘

function VehiclePlateChangedInventory(oldPlate, newPlate, netId)
    -- This inventory does not support updating vehicle trunk plates, so no action is required here.
end