if Cfg.Inventory ~= 'origen_inventory' then return end

local ItemList = {}
local InventoryImages = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
function AddItem(source, item_name, amount, metadata)
    return exports.origen_inventory:addItem(source, item_name, amount, metadata)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount, slot)
    return exports.origen_inventory:removeItem(source, item_name, amount, nil, slot)
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    amount = amount or 1
    local hasItem = exports.origen_inventory:getItem(source, item_name, false, true)
    return hasItem
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item_count = exports.origen_inventory:getItemCount(source, item_name)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports.origen_inventory:canCarryItem(source, item_name, amount)
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
    local inventory = exports.origen_inventory:getInventoryItems(source)
    if not inventory then return {} end

    local normalisedInventory = {}
    for index, item in pairs(inventory) do
        if index ~= nil and item then
            table.insert(normalisedInventory, {
                name = item.name,
                label = item.label,
                amount = item.amount or item.count,
                slot = item.slot or index,
                metadata = item.metadata or {},
                quality = item.metadata and item.metadata.quality
            })
        end
    end
    return normalisedInventory
end

-- Get item information from a specific slot
function GetItemFromSlot(source, slot)
    local item = exports.origen_inventory:getSlot(source, slot)
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
    local newQuality = (metadata and metadata.quality) + qualityIncrease
    if newQuality > 100 then newQuality = 100 end

    metadata.quality = newQuality
    exports.origen_inventory:setMetadata(source, slot, metadata)
end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    local newQuality = (metadata and metadata.quality) - qualityDecrease
    if newQuality > 100 then newQuality = 100 end

    metadata.quality = newQuality
    exports.origen_inventory:setMetadata(source, slot, metadata)
end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
function SetItemQuality(source, slot, quality, itemName)
    local metadata = GetItemMetadata(source, slot) or {}
    metadata.quality = quality
    exports.origen_inventory:setMetadata(source, slot, metadata)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player can carry a specific item and amount
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end

    local items = exports.origen_inventory:Items()
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
        GetResourcePath('origen_inventory')..'/web/build/images',
        'origen_inventory/web/build/images/',
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
    -- This inventory does not support updating vehicle trunk plates, so no action is required here.
end