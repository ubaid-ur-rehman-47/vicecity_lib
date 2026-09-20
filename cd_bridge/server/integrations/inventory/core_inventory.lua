if Cfg.Inventory ~= 'core_inventory' then return end

local ItemList = {}
local InventoryImages = {}

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      BASIC ITEM FUNCTIONS                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Add item to a player's inventory
function AddItem(source, item_name, amount, metadata)
    return exports.core_inventory:addItem(source, item_name, amount, metadata)
end

-- Remove item from a player's inventory
function RemoveItem(source, item_name, amount, slot)
    if not slot then
        return exports.core_inventory:removeItem(source, item_name, amount)
    else
        return exports.core_inventory:removeItemExact(source, slot, amount)
    end
end

-- Check if a player has a specific item and amount
function HasItem(source, item_name, amount)
    amount = amount or 1
    return exports.core_inventory:hasItem(source, item_name, amount)
end

-- Get the count of a specific item in a player's inventory
function GetItemCount(source, item_name)
    local item_count = exports.core_inventory:getItemCount(source, item_name)
    if item_count then
        return item_count
    end
    return 0
end

-- Check if a player can carry a specific item and amount
function CanCarryItem(source, item_name, amount)
    return exports.core_inventory:canCarry(source, item_name, amount)
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
    local inventory = exports.core_inventory:getInventory(source)
    if not inventory then return {} end

    local normalisedInventory = {}
    for slot, item in pairs(inventory.content) do
        if slot ~= nil and item then
            table.insert(normalisedInventory, {
                name = item.name,
                label = item.label,
                amount = item.amount or item.count,
                slot = slot,
                metadata = {quality = item.quality},
                quality = item.quality
            })
        end
    end
    return normalisedInventory
end

-- Get item information from a specific slot
function GetItemFromSlot(source, slot)
    local item = exports.core_inventory:getItemBySlot(source, slot)
    return item and {
        name = item.name,
        label = item.label,
        amount = item.amount or item.count,
        slot = item.slot,
        metadata = {quality = item.quality},
        quality = item.quality
    }
end

-- Add quality to an item in a specific slot, or to the first item matching the itemName
function AddQualityToItem(source, slot, qualityIncrease, itemName)
    local currentQuality = GetItemQuality(source, slot) or 0
    local newQuality = currentQuality + qualityIncrease
    if newQuality > 100 then newQuality = 100 end

    exports.core_inventory:setDurability(source, itemName, slot, newQuality)
end

-- Remove quality from an item in a specific slot, or from the first item matching the itemName
function RemoveQualityFromItem(source, slot, qualityDecrease, itemName)
    exports.core_inventory:removeDurability(source, itemName, slot, qualityDecrease)
end

-- Set the quality of an item in a specific slot, or of the first item matching the itemName
function SetItemQuality(source, slot, quality, itemName)
    exports.core_inventory:setDurability(source, itemName, slot, quality)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           GET SHARED DATA                        │
-- └──────────────────────────────────────────────────────────────────┘

-- Check if a player can carry a specific item and amount
function GetItemList()
    if next(ItemList) ~= nil then
        return ItemList
    end

    local items = exports.core_inventory:getItemsList()
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
        GetResourcePath('core_inventory')..'/html/images',
        'core_inventory/html/images/',
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