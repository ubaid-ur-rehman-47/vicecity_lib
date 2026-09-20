if Cfg.Inventory ~= 'ak47_inventory' then return end

local ItemList = {}
local InventoryImages = {}

local resourceName = GetCurrentResourceName() == 'ak47_inventory' and 'ak47_inventory' or 'ak47_qb_inventory'

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
function AddItem(source, item_name, amount, metadata)
    return exports[resourceName]:AddItem(source, item_name, amount, nil, metadata)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount, slot)
    return exports[resourceName]:RemoveItem(source, item_name, amount, slot)
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    amount = amount or 1
    local items = {[item_name] = amount}
    local hasItem = exports[resourceName]:HasItems(source, items)
    return hasItem
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item_count = exports[resourceName]:GetAmount(source, item_name)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports[resourceName]:CanAddItem(source, item_name, amount)
end

-- Add weapon to a player's inventory
function AddWeapon(source, weapon_name, ammo)
    return AddItem(source, weapon_name, 1, { ammo = ammo })
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           ITEM METADATA                          │
-- └──────────────────────────────────────────────────────────────────┘

local function normaliseItemInfo(item)
    if not item then return {}, nil end

    local info = item.info
    local metadata = type(info) == 'table' and info or {}
    local quality = item.quality

    if quality == nil then
        if type(info) == 'table' then
            quality = info.quality
        elseif type(info) == 'number' then
            quality = info
            metadata.quality = info
        end
    end

    return metadata, quality
end

-- Returns the players full inventory
function GetPlayerInventory(source)
    local inventory = exports[resourceName]:GetInventoryItems(source)
    if not inventory then return {} end

    local normalisedInventory = {}
    for index, item in pairs(inventory) do
        if index ~= nil and item then
            local metadata, quality = normaliseItemInfo(item)
            table.insert(normalisedInventory, {
                name = item.name,
                label = item.label,
                amount = item.amount or item.count,
                slot = item.slot or index,
                metadata = metadata,
                quality = quality
            })
        end
    end
    return normalisedInventory
end

-- Get item information from a specific slot
function GetItemFromSlot(source, slot)
    local item = exports[resourceName]:GetSlot(source, slot)
    local metadata, quality = normaliseItemInfo(item)
    return item and {
        name = item.name,
        label = item.label,
        amount = item.amount,
        slot = item.slot,
        metadata = metadata,
        quality = quality
    }
end

-- Add quality to an item in a specific slot, or to the first item matching the itemName
function AddQualityToItem(source, slot, qualityIncrease, itemName)
    local currentQuality = GetItemQuality(source, slot) or 0
    local newQuality = currentQuality + qualityIncrease
    if newQuality > 100 then newQuality = 100 end

    exports[resourceName]:SetQuality(source, slot, newQuality)
end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)
    exports[resourceName]:RemoveQuality(source, slot, qualityDecrease)
end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
function SetItemQuality(source, slot, quality, itemName)
    exports[resourceName]:SetQuality(source, slot, quality)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player can carry a specific item and amount
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end

    local items = exports[resourceName]:Items()
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
        GetResourcePath(resourceName)..'/web/build/images',
        resourceName..'/web/build/images/',
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
    exports[resourceName]:OnChangeVehiclePlate(oldPlate, newPlate)
end