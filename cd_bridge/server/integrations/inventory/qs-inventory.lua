if Cfg.Inventory ~= 'qs-inventory' then return end

local ItemList = {}
local InventoryImages = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
function AddItem(source, item_name, amount, metadata)
    return exports['qs-inventory']:AddItem(source, item_name, amount, nil, metadata)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount, slot)
    return exports['qs-inventory']:RemoveItem(source, item_name, amount, slot)
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    amount = amount or 1
    local hasItem = exports['qs-inventory']:GetItemTotalAmount(source, item_name)
    if hasItem >= amount then
        return true
    end
    return false
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item_count = exports['qs-inventory']:GetItemTotalAmount(source, item_name)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports['qs-inventory']:CanCarryItem(source, item_name, amount)
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
    local inventory = exports['qs-inventory']:GetInventory(source)

    local normalisedInventory = {}
    for slot, item in pairs(inventory) do
        if slot ~= nil and item then
            table.insert(normalisedInventory, {
                name = item.name,
                label = item.label,
                amount = item.amount,
                slot = slot,
                metadata = item.info or {},
                quality = item.info and item.info.quality
            })
        end
    end
    return normalisedInventory
end

-- Get item information from a specific slot
function GetItemFromSlot(source, slot)
    local inventory = GetPlayerInventory(source)

    for _, item in pairs(inventory) do
        if item and item.slot == slot then
            return item and {
                name = item.name,
                label = item.label,
                amount = item.amount,
                slot = item.slot,
                metadata = item.metadata,
                quality = item.quality
            }
        end
    end
end

-- Add quality to an item in a specific slot, or to the first item matching the itemName
function AddQualityToItem(source, slot, qualityIncrease, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    local newQuality = (metadata and metadata.quality or 0) + qualityIncrease
    if newQuality > 100 then newQuality = 100 end

    metadata.quality = newQuality
    exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    local newQuality = (metadata and metadata.quality or 0) - qualityDecrease
    if newQuality < 0 then newQuality = 0 end

    metadata.quality = newQuality
    exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
function SetItemQuality(source, slot, quality, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    metadata.quality = quality
    exports['qs-inventory']:SetItemMetadata(source, slot, metadata)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player can carry a specific item and amount
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end

    local items = exports['qs-inventory']:GetItemList()
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

-- Get inventory images
function GetInventoryImages()
    if next(InventoryImages) ~= nil then
        return InventoryImages
    end
    local images = exports.cd_bridge:ReadNUIDirectory(
        GetResourcePath('qs-inventory')..'/html/images',
        'qs-inventory/html/images/',
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
    exports['qs-inventory']:UpdateVehiclePlate(oldPlate, newPlate)
end