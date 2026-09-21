--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

lib.callback.register('cubx_inventory:renameItem', function(source, slot, name)
    local inventory = exports.ox_inventory:GetInventory(source)
    if not inventory then return false end

    local item = inventory.items[slot]
    if not item then return false end

    local metadata = item.metadata or {}
    metadata.label = name

    exports.ox_inventory:SetMetadata(source, slot, metadata)
    return true
end)