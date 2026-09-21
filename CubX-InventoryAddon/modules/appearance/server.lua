--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

lib.callback.register("cubx_inventory:unequipOutfit", function(source)
    return true
end)

lib.callback.register("cubx_inventory:toggleClothingVisibility", function(source, slotKey, hidden)
    return true
end)

lib.callback.register("cubx_inventory:unequipClothing", function(source, name, targetSlot, currentComponents)
    if not currentComponents or not currentComponents[name] then
        print("[CubX] unequipClothing failed: missing components for " .. tostring(name))
        return false
    end
    
    local metadata = {
        components = currentComponents,
        label = "Custom " .. (name:gsub("^%l", string.upper))
    }
    
    local success = exports.ox_inventory:AddItem(source, name, 1, metadata, targetSlot)
    if success then
        return { components = currentComponents }
    end
    
    return false
end)

lib.callback.register("cubx_inventory:equipClothing", function(source, slot)
    local item = exports.ox_inventory:GetSlot(source, slot)
    
    if not item or not item.metadata or not item.metadata.components then
        print("[CubX] equipClothing failed: item missing metadata components in slot " .. tostring(slot))
        return false
    end
    
    local success = exports.ox_inventory:RemoveItem(source, item.name, 1, nil, slot)
    
    if success then
        return {
            components = item.metadata.components
        }
    end
    
    return false
end)

lib.callback.register("cubx_inventory:equipOutfit", function(source, slot)
    return true
end)

lib.callback.register("cubx_inventory:saveOutfit", function(source, slot, components, name)
    local metadata = {
        components = components,
        label = name,
        description = "Tenue: " .. name
    }
    exports.ox_inventory:SetMetadata(source, slot, metadata)
    return true
end)