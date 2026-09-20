if Cfg.Inventory ~= 'tgiann-inventory' then return end

local ItemList = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
function AddItem(source, item_name, amount, metadata)
    return exports['tgiann-inventory']:AddItem(source, item_name, amount, nil, metadata)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount, slot)
    return exports['tgiann-inventory']:RemoveItem(source, item_name, amount, slot)
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    amount = amount or 1
    return exports['tgiann-inventory']:HasItem(source, item_name, amount)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item_count = exports['tgiann-inventory']:GetItemCount(source, item_name)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports['tgiann-inventory']:CanCarryItem(source, item_name, amount)
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    return AddItem(source, weapon_name, 1, { ammo = ammo })
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           ITEM METADATA                          │
-- └──────────────────────────────────────────────────────────────────┘

-- Returns the players full inventory
function GetPlayerInventory(source)
    local inventory = exports['tgiann-inventory']:GetPlayerItems(source)
    if not inventory then return {} end

    local normalisedInventory = {}
    for _, item in pairs(inventory) do
        if item then
            table.insert(normalisedInventory, {
                name = item.name,
                label = item.label,
                amount = item.amount or item.count,
                slot = item.slot,
                metadata = item.metadata or {},
                quality = item.metadata and item.metadata.quality
            })
        end
    end
    return normalisedInventory
end

function GetItemFromSlot(source, slot)
    local item = exports['tgiann-inventory']:GetItemBySlot(source, slot)
    return item and {
        name = item.name,
        label = item.label,
        amount = item.amount or item.count,
        slot = item.slot,
        metadata = item.metadata or {},
        quality = item.metadata and item.metadata.quality
    }
end

-- Add quality to an item in a specific slot, or to the first item matching the itemName
function AddQualityToItem(source, slot, qualityIncrease, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    local newQuality = (metadata and metadata.quality or 0) + qualityIncrease
    if newQuality > 100 then newQuality = 100 end

    metadata.quality = newQuality
    exports['tgiann-inventory']:UpdateItemMetadata(src, itemName, slot, metadata)
end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    local newQuality = (metadata and metadata.quality or 0) - qualityDecrease
    if newQuality < 0 then newQuality = 0 end

    metadata.quality = newQuality
    exports['tgiann-inventory']:UpdateItemMetadata(src, itemName, slot, metadata)
end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
function SetItemQuality(source, slot, quality, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    metadata.quality = quality
    exports['tgiann-inventory']:UpdateItemMetadata(src, itemName, slot, metadata)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Get the list of all items in the database
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end
    for _, row in pairs(exports['tgiann-inventory']:GetItemList()) do
        ItemList[row.name] = {
            name = row.name,
            label = row.label
        }
    end
    return ItemList
end

-- Get inventory images
function GetInventoryImages()
    if next(InventoryImages) ~= nil then
        return InventoryImages
    end
    local images = exports.cd_bridge:ReadNUIDirectory(
        GetResourcePath('tgiann-inventory')..'/inventory_images/images',
        'tgiann-inventory/inventory_images/images/',
        {'png', 'jpg', 'jpeg', 'gif', 'webp'}
    )
    if images then
        InventoryImages = images
    end
    return InventoryImages
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                OTHER                             │
-- └──────────────────────────────────────────────────────────────────┘

function VehiclePlateChangedInventory(oldPlate, newPlate, netId)
    exports['tgiann-inventory']:UpdateVehicle(oldPlate, newPlate)
end