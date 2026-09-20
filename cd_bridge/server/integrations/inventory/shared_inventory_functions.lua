-- ┌──────────────────────────────────────────────────────────────────┐
-- │                                OTHER                             │
-- └──────────────────────────────────────────────────────────────────┘

if IsBridgeResource() then -- events inside here to prevent multiple events being loaded
    RegisterServerEvent('cd_bridge:AddItem', function(item_name, amount, metadata, src)
        src = source or src
        AddItem(src, item_name, amount, metadata)
    end)

    RegisterServerEvent('cd_bridge:RemoveItem', function(item_name, amount, src)
        src = source or src
        RemoveItem(src, item_name, amount)
    end)

    RegisterServerEvent('cd_bridge:RemoveItemWithMetadata', function(item_name, amount, metadata, src)
        src = source or src
        RemoveItemWithMetadata(src, item_name, amount, metadata)
    end)

    RegisterServerEvent('cd_bridge:VehiclePlateChanged', function(oldPlate, newPlate, netId)
        VehiclePlateChangedInventory(oldPlate, newPlate, netId)
        TriggerClientEvent('cd_bridge:VehiclePlateChanged', -1, oldPlate, newPlate, netId)

        local vehicleId = WaitForEntityFromNetId(netId, 5000)
        if not vehicleId or not DoesEntityExist(vehicleId) then
            ERROR('7453', 'invalid vehicle from netId: '..tostring(netId))
            return
        end
        SetVehicleNumberPlateText(vehicleId, newPlate)
    end)
end

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           ITEM METADATA                          │
-- └──────────────────────────────────────────────────────────────────┘

local function metadataMatches(itemMetadata, requiredMetadata)
    if type(requiredMetadata) ~= 'table' then return true end
    if type(itemMetadata) ~= 'table' then return false end

    for key, value in pairs(requiredMetadata) do
        if type(value) == 'table' then
            if not metadataMatches(itemMetadata[key], value) then
                return false
            end
        elseif itemMetadata[key] ~= value then
            return false
        end
    end

    return true
end

-- Checks if the player has at least 1 of the item with matching metadata
--- @param source number The player's server ID.
--- @param item_name string The item to check.
--- @param metadata table The item metadata to match.
--- @return boolean # True if the player has at least 1 of the item with matching metadata, false otherwise.
function HasItemWithMetadata(source, item_name, metadata)
    local inventory = GetPlayerInventory(source)

    for _, item in pairs(inventory) do
        if item.name == item_name and metadataMatches(item.metadata, metadata) then
            return true
        end
    end

    return false
end

-- Remove item from a player's inventory with matching metadata
--- @param source number The player's server ID.
--- @param item_name string The item to remove.
--- @param amount number The amount remove.
--- @param metadata number The item metadata to match.
--- @return boolean # True if the item was removed successfully, false otherwise.
function RemoveItemWithMetadata(source, item_name, amount, metadata)
    local inventory = GetPlayerInventory(source)
    local slot = nil

    for _, item in pairs(inventory) do
        if item.name == item_name and metadataMatches(item.metadata, metadata) then
            slot = item.slot
        end
    end

    if not slot then return false end
    return RemoveItem(source, item_name, amount, slot)
end

-- Returns the slot ID of the first item that matches the item_name
--- @param source number The player's server ID.
--- @param item_name string The item name.
--- @return number|nil # The slot ID of the first item that matches the item_name, or nil if no item was found.
function GetSlotFromFirstItemFound(source, item_name)
    local inventory = GetPlayerInventory(source) or {}

    for _, item in pairs(inventory) do
        if item and item.name == item_name then
            return item.slot
        end
    end

    return nil
end

-- Returns the slot ID of any item that matches the item_name and has no quality
--- @param source number The player's server ID.
--- @param item_name string The item name.
--- @return number|nil # The slot ID of any item that matches the item_name and has no quality, or nil if no item was found.
function GetSlotWithNoQuality(source, item_name)
    local inventory = GetPlayerInventory(source) or {}

    for _, item in pairs(inventory) do
        if item and item.name == item_name and item.quality == nil then
            return item.slot
        end
    end

    return nil
end

-- Returns the slot ID of any item that matches the item_name and quality
--- @param source number The player's server ID.
--- @param item_name string The item name.
--- @param quality number The item quality.
--- @return number|nil # The slot ID of the first item that matches the item_name and quality, or nil if no item was found.
function GetSlotFromMatchingNameAndQuality(source, item_name, quality)
    local inventory = GetPlayerInventory(source) or {}

    for _, item in pairs(inventory) do
        if item and item.name == item_name and item.quality and item.quality == quality then
            return item.slot
        end
    end

    return nil
end

-- Get the metadata of an item in a specific slot, or of the first item matching the item_name
--- @param source number The player's server ID.
--- @param slot number The inventory slot id.
--- @return table|nil # The metadata of the item, or nil if no item was found or if the item has no metadata.
function GetItemMetadata(source, slot)
    local item = GetItemFromSlot(source, slot)
    return item and item.metadata or {}
end

-- Get the quality of an item in a specific slot, or of the first item matching the item_name
--- @param source number The player's server ID.
--- @param slot number|nil The inventory slot id.
--- @return number|nil # The quality of the item, or nil if no item was found.
function GetItemQuality(source, slot)
    local item = GetItemFromSlot(source, slot)
    return item and item.quality or nil
end