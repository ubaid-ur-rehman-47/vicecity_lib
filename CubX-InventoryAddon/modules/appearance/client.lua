--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

CubXAppearance = {}
local equippedAccessories = {}
local lockedSlots = {}
local currentOutfit = nil
local originalAppearance = nil

local clothingMap = {
    mask = 1,
    arms = 3,
    legs = 4,
    bag = 5,
    shoes = 6,
    necklace = 7,
    undershirt = 8,
    armor = 9,
    decals = 10,
    torso = 11
}

local propMap = {
    hat = 0,
    glasses = 1,
    ears = 2,
    watch = 6,
    bracelet = 7
}

function CubXAppearance.Apply(components)
    if not components then return end
    for name, data in pairs(components) do
        local isClothing = clothingMap[name]
        local isProp = propMap[name]
        if isProp then
            exports["CubX-Bridge"]:SetPedProp(nil, isProp, data.drawable, data.texture)
        elseif isClothing then
            exports["CubX-Bridge"]:SetPedComponent(nil, isClothing, data.drawable, data.texture)
        end
    end
end

function CubXAppearance.Remove(components)
    if not components then return end
    for name in pairs(components) do
        local isProp = propMap[name]
        local isClothing = clothingMap[name]
        if isProp then
            exports["CubX-Bridge"]:SetPedProp(nil, isProp, -1, 0)
        elseif isClothing then
            if originalAppearance and originalAppearance.components and originalAppearance.components[isClothing] then
                local compData = originalAppearance.components[isClothing]
                exports["CubX-Bridge"]:SetPedComponent(nil, isClothing, compData.drawable, compData.texture)
            else
                exports["CubX-Bridge"]:SetPedComponent(nil, isClothing, 0, 0)
            end
        end
    end
end

function CubXAppearance.RestoreAll()
    originalAppearance = exports["CubX-Bridge"]:GetPedAppearance()
    for _, item in ipairs(equippedAccessories) do
        if item.metadata and item.metadata.components then
            CubXAppearance.Apply(item.metadata.components)
        end
    end
    if currentOutfit and currentOutfit.metadata and currentOutfit.metadata.components then
        local hiddenSlots = currentOutfit.hiddenSlots or {}
        for name, comp in pairs(currentOutfit.metadata.components) do
            if not hiddenSlots[name] then
                CubXAppearance.Apply({[name] = comp})
            end
        end
    end
end

function CubXAppearance.IsLocked(slot)
    return lockedSlots[slot] == true
end

function CubXAppearance.GetEquipped()
    return equippedAccessories
end

function CubXAppearance.GetLockedSlots()
    return lockedSlots
end

function CubXAppearance.AddEquipped(item)
    if item.metadata and item.metadata.components then
        for name in pairs(item.metadata.components) do
            for i = #equippedAccessories, 1, -1 do
                local eqItem = equippedAccessories[i]
                if eqItem.metadata and eqItem.metadata.components and eqItem.metadata.components[name] then
                    table.remove(equippedAccessories, i)
                    break
                end
            end
        end
    end
    equippedAccessories[#equippedAccessories + 1] = item
end

function CubXAppearance.RemoveEquipped(itemName)
    for i = #equippedAccessories, 1, -1 do
        if equippedAccessories[i].name == itemName then
            table.remove(equippedAccessories, i)
            return
        end
    end
end

function CubXAppearance.SetCurrentOutfit(outfit)
    currentOutfit = outfit
end

function CubXAppearance.SetLockedSlots(slots)
    lockedSlots = {}
    if slots then
        for _, slot in ipairs(slots) do
            lockedSlots[slot] = true
        end
    end
    exports.ox_inventory:sendNuiMessage({
        action = "updateLockedSlots",
        data = lockedSlots
    })
end

local function playClothingAnim(animType)
    local animConfig = CubXClothingData and CubXClothingData.animations and CubXClothingData.animations[animType]
    if not animConfig then return true end
    
    lib.requestAnimDict(animConfig.dict)
    
    local label = locale("equipping_" .. animType) or locale("equipping") or "Equipping..."
    
    local success = lib.progressBar({
        duration = animConfig.duration,
        label = label,
        useWhileDead = false,
        canCancel = true,
        disable = { combat = true, move = true },
        anim = { dict = animConfig.dict, clip = animConfig.name, flag = animConfig.flags }
    })
    
    RemoveAnimDict(animConfig.dict)
    return success
end

local function playOutfitRemoveAnim(cb)
    if currentOutfit then
        local animConfig = CubXClothingData and CubXClothingData.animations and CubXClothingData.animations.outfit
        if animConfig then
            lib.requestAnimDict(animConfig.dict)
            
            local label = locale("unequipping_outfit") or "Removing outfit..."
            
            local success = lib.progressBar({
                duration = animConfig.duration,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = { combat = true, move = true },
                anim = { dict = animConfig.dict, clip = animConfig.name, flag = animConfig.flags }
            })
            
            RemoveAnimDict(animConfig.dict)
            if not success then return cb(false) end
        end
        
        local response = lib.callback.await("cubx_inventory:unequipOutfit", false)
        if response then
            local gender = exports["CubX-Bridge"]:GetPedModel() == 1885233650 and "m" or "f"
            local defaults = CubXClothingDefaults and CubXClothingDefaults[gender]
            
            local componentsToReset = {}
            if currentOutfit and currentOutfit.metadata and currentOutfit.metadata.components then
                for name in pairs(currentOutfit.metadata.components) do
                    componentsToReset[#componentsToReset + 1] = name
                end
            end
            
            for _, name in ipairs(componentsToReset) do
                local defData = defaults and defaults[name]
                if defData then
                    local isProp = propMap[name]
                    local isClothing = clothingMap[name]
                    if isProp then
                        exports["CubX-Bridge"]:SetPedProp(nil, isProp, defData.drawable, defData.texture)
                    elseif isClothing then
                        exports["CubX-Bridge"]:SetPedComponent(nil, isClothing, defData.drawable, defData.texture)
                    end
                else
                    CubXAppearance.Remove({[name] = true})
                end
            end
            
            currentOutfit = nil
            lockedSlots = {}
            
            exports.ox_inventory:sendNuiMessage({
                action = "outfitUnequipped",
                data = { componentsToReset = componentsToReset }
            })
            
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end

function CubXAppearance.HandleToggleClothingVisibility(data, cb)
    local slotKey = data.slotKey
    local hidden = data.hidden
    
    if not slotKey then return cb(false) end
    
    local animConfig = CubXClothingData and CubXClothingData.animations and CubXClothingData.animations[slotKey]
    if animConfig then
        lib.requestAnimDict(animConfig.dict)
        local duration = math.floor(animConfig.duration * 0.6)
        
        local label
        if hidden then
            label = locale("hiding_" .. slotKey) or locale("hiding_clothing") or "Hiding..."
        else
            label = locale("showing_" .. slotKey) or locale("showing_clothing") or "Showing..."
        end
        
        local success = lib.progressBar({
            duration = duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = { combat = true, move = true },
            anim = { dict = animConfig.dict, clip = animConfig.name, flag = animConfig.flags }
        })
        
        RemoveAnimDict(animConfig.dict)
        if not success then return cb(false) end
    end
    
    if hidden then
        local gender = exports["CubX-Bridge"]:GetPedModel() == 1885233650 and "m" or "f"
        local defaults = CubXClothingDefaults and CubXClothingDefaults[gender]
        local defData = defaults and defaults[slotKey]
        
        if defData then
            local isProp = propMap[slotKey]
            local isClothing = clothingMap[slotKey]
            if isProp then
                exports["CubX-Bridge"]:SetPedProp(nil, isProp, defData.drawable, defData.texture)
            elseif isClothing then
                exports["CubX-Bridge"]:SetPedComponent(nil, isClothing, defData.drawable, defData.texture)
            end
        else
            CubXAppearance.Remove({[slotKey] = true})
        end
    else
        if currentOutfit and currentOutfit.metadata and currentOutfit.metadata.components and currentOutfit.metadata.components[slotKey] then
            CubXAppearance.Apply({[slotKey] = currentOutfit.metadata.components[slotKey]})
        end
    end
    
    if currentOutfit then
        currentOutfit.hiddenSlots = currentOutfit.hiddenSlots or {}
        currentOutfit.hiddenSlots[slotKey] = hidden or nil
    end
    
    lib.callback.await("cubx_inventory:toggleClothingVisibility", false, slotKey, hidden)
    cb(true)
end

function CubXAppearance.HandleUnequipClothing(data, cb)
    local name = data.name
    if not name then return cb(false) end
    
    if name == "outfit" then
        if currentOutfit then
            return playOutfitRemoveAnim(cb)
        end
    end
    
    for _, item in ipairs(equippedAccessories) do
        if item.name == name then
            if item.metadata and item.metadata.components then
                for compName in pairs(item.metadata.components) do
                    if lockedSlots[compName] then
                        lib.notify({
                            type = "error",
                            description = locale("slot_locked")
                        })
                        return cb(false)
                    end
                end
            end
        end
    end
    
    local animConfig = CubXClothingData and CubXClothingData.animations and CubXClothingData.animations[name]
    if animConfig then
        lib.requestAnimDict(animConfig.dict)
        
        local label = locale("unequipping_" .. name) or locale("unequipping") or "Removing..."
        
        local success = lib.progressBar({
            duration = animConfig.duration,
            label = label,
            useWhileDead = false,
            canCancel = true,
            disable = { combat = true, move = true },
            anim = { dict = animConfig.dict, clip = animConfig.name, flag = animConfig.flags }
        })
        
        RemoveAnimDict(animConfig.dict)
        if not success then return cb(false) end
    end
    
    local currentComponents = {}
    local foundInEquipped = false
    for _, item in ipairs(equippedAccessories) do
        if item.name == name then
            foundInEquipped = true
            if item.metadata and item.metadata.components then
                currentComponents = item.metadata.components
            end
            break
        end
    end

    local needsPedFallback = not foundInEquipped or next(currentComponents) == nil

    if needsPedFallback then
        local isClothing = clothingMap[name]
        local isProp = propMap[name]
        local ped = PlayerPedId()

        if isClothing then
            local drawable = GetPedDrawableVariation(ped, isClothing)
            local texture  = GetPedTextureVariation(ped, isClothing)
            currentComponents[name] = { drawable = drawable, texture = texture }
        elseif isProp then
            local drawable = GetPedPropIndex(ped, isProp)
            local texture  = GetPedPropTextureIndex(ped, isProp)
            if drawable ~= -1 then
                currentComponents[name] = { drawable = drawable, texture = texture }
            end
        end
    end

    local response = lib.callback.await("cubx_inventory:unequipClothing", false, name, data.targetSlot, currentComponents)
    if response then
        if response.components then
            local gender = exports["CubX-Bridge"]:GetPedModel() == 1885233650 and "m" or "f"
            local defaults = CubXClothingDefaults and CubXClothingDefaults[gender]

            for compName in pairs(response.components) do
                local defData = defaults and defaults[compName]
                if defData then
                    local isProp = propMap[compName]
                    local isClothing = clothingMap[compName]
                    if isProp then
                        exports["CubX-Bridge"]:SetPedProp(nil, isProp, defData.drawable, defData.texture)
                    elseif isClothing then
                        exports["CubX-Bridge"]:SetPedComponent(nil, isClothing, defData.drawable, defData.texture)
                    end
                else
                    CubXAppearance.Remove({[compName] = true})
                end
            end

            CubXAppearance.RemoveEquipped(name)

            exports.ox_inventory:sendNuiMessage({
                action = "clothingUnequipped",
                data = { name = name }
            })

            if exports["CubX-Bridge"]:GetAppearanceSystem() then
                TriggerEvent("cbux:client:saveAppearance")
            end

            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end

function CubXAppearance.HandleUnequipOutfit(data, cb)
    playOutfitRemoveAnim(cb)
end

function CubXAppearance.EquipClothingItem(item, slotData)
    local itemName = (slotData and slotData.name) or item.name
    local itemSlot = (slotData and slotData.slot) or item.slot
    local itemMeta  = (slotData and slotData.metadata) or item.metadata


    if not playClothingAnim(itemName) then
        return
    end

    local response = lib.callback.await("cubx_inventory:equipClothing", false, itemSlot)


    if response then
        if response.replaced then
            for _, replacedItem in ipairs(response.replaced) do
                CubXAppearance.RemoveEquipped(replacedItem.name)
                exports.ox_inventory:sendNuiMessage({
                    action = "clothingUnequipped",
                    data = { name = replacedItem.name }
                })
            end
        end

        CubXAppearance.Apply(response.components)

        CubXAppearance.AddEquipped({
            name = itemName,
            label = itemMeta and itemMeta.label or itemName,
            metadata = itemMeta
        })

        if exports["CubX-Bridge"]:GetAppearanceSystem() then
            TriggerEvent("cbux:client:saveAppearance")
        end

    else
    end
end

function CubXAppearance.EquipOutfitItem(item, slotData)
    local realItem = slotData or item
    local itemName = (slotData and slotData.name) or item.name
    local itemSlot = (slotData and slotData.slot) or item.slot
    local itemMeta = (slotData and slotData.metadata) or item.metadata
    local components = itemMeta and itemMeta.components

    if not components then
        local input = lib.inputDialog("Enregistrer la tenue", {
            { type = 'input', label = 'Nom de la tenue', placeholder = 'Ma tenue', required = true }
        })
        if not input or not input[1] then return end
        local outfitName = input[1]

        local ped = PlayerPedId()
        local currentComponents = {}
        for name, id in pairs(clothingMap) do
            local drawable = GetPedDrawableVariation(ped, id)
            local texture = GetPedTextureVariation(ped, id)
            currentComponents[name] = { drawable = drawable, texture = texture }
        end
        for name, id in pairs(propMap) do
            local drawable = GetPedPropIndex(ped, id)
            local texture = GetPedPropTextureIndex(ped, id)
            if drawable ~= -1 then
                currentComponents[name] = { drawable = drawable, texture = texture }
            end
        end

        local success = lib.callback.await("cubx_inventory:saveOutfit", false, itemSlot, currentComponents, outfitName)
        if success then
            lib.notify({ type = 'success', description = "Tenue enregistrée avec succès!" })
        end
        return
    end

    if not playClothingAnim("outfit") then return end
    
    local response = lib.callback.await("cubx_inventory:equipOutfit", false, itemSlot)
    if response then
        local components = type(response) == "table" and response.components or itemMeta.components
        local lockedSlots = type(response) == "table" and response.lockedSlots or itemMeta.lockedSlots or {}

        if components then
            CubXAppearance.Apply(components)
        end
        
        CubXAppearance.SetCurrentOutfit({
            name = itemMeta.label or itemName,
            metadata = itemMeta
        })
        
        CubXAppearance.SetLockedSlots(lockedSlots)
        
        local equippedSlots = {}
        equippedSlots.outfit = {
            name = "outfit",
            label = itemMeta.label or itemName
        }
        
        local itemsConfig = exports.ox_inventory:Items()
        if components then
            for compName in pairs(components) do
                local configItem = itemsConfig and itemsConfig[compName]
                equippedSlots[compName] = {
                    name = compName,
                    label = configItem and configItem.label or compName
                }
            end
        end
        
        exports.ox_inventory:sendNuiMessage({
            action = "outfitEquipped",
            data = {
                outfit = {
                    name = itemName,
                    label = itemMeta.label or itemName
                },
                equippedSlots = equippedSlots,
                lockedSlots = lockedSlots
            }
        })
        
        if exports["CubX-Bridge"]:GetAppearanceSystem() then
            TriggerEvent("cbux:client:saveAppearance")
        end
    end
end

RegisterNetEvent("cubx_inventory:loadAccessories", function(accessories, outfit)
    equippedAccessories = accessories or {}
    if outfit then
        currentOutfit = {
            name = outfit.name,
            metadata = outfit.metadata,
            hiddenSlots = outfit.hiddenSlots or {}
        }
        
        lockedSlots = {}
        if outfit.lockedSlots then
            for _, slot in pairs(outfit.lockedSlots) do
                lockedSlots[slot] = true
            end
        end
    else
        currentOutfit = nil
        lockedSlots = {}
    end
    
    CubXAppearance.RestoreAll()
end)

RegisterNetEvent("cubx_inventory:updateLockedSlots", function(slots)
    lockedSlots = {}
    if slots then
        for _, slot in ipairs(slots) do
            lockedSlots[slot] = true
        end
    end
    exports.ox_inventory:sendNuiMessage({
        action = "updateLockedSlots",
        data = lockedSlots
    })
end)

function CubXAppearance.GetEquippedForNUI()
    local equippedItems = {}
    local ped = PlayerPedId()
    local gender = exports["CubX-Bridge"]:GetPedModel() == 1885233650 and "m" or "f"
    local defaults = CubXClothingDefaults and CubXClothingDefaults[gender] or {}
    local itemsConfig = exports.ox_inventory:Items()

    for compName, compId in pairs(clothingMap) do
        local drawable = GetPedDrawableVariation(ped, compId)
        local defData = defaults[compName]
        local isDefault = (defData and defData.drawable == drawable) or (not defData and drawable == 0)
        
        if not isDefault then
            local configItem = itemsConfig and itemsConfig[compName]
            equippedItems[compName] = {
                name = compName,
                label = configItem and configItem.label or compName
            }
        end
    end
    
    for compName, compId in pairs(propMap) do
        local drawable = GetPedPropIndex(ped, compId)
        local defData = defaults[compName]
        local isDefault = (defData and defData.drawable == drawable) or (not defData and drawable == -1)
        
        if not isDefault then
            local configItem = itemsConfig and itemsConfig[compName]
            equippedItems[compName] = {
                name = compName,
                label = configItem and configItem.label or compName
            }
        end
    end

    for _, item in ipairs(equippedAccessories) do
        if item.metadata and item.metadata.components then
            for compName in pairs(item.metadata.components) do
                equippedItems[compName] = {
                    name = item.name,
                    label = item.label or (item.metadata and item.metadata.label)
                }
            end
        end
    end
    
    local hiddenSlots = {}
    if currentOutfit and currentOutfit.metadata and currentOutfit.metadata.components then
        equippedItems.outfit = {
            name = "outfit",
            label = currentOutfit.name
        }
        
        local itemsConfig = exports.ox_inventory:Items()
        for compName in pairs(currentOutfit.metadata.components) do
            local configItem = itemsConfig and itemsConfig[compName]
            equippedItems[compName] = {
                name = compName,
                label = configItem and configItem.label or compName
            }
        end
        
        if currentOutfit.hiddenSlots then
            for slot, hidden in pairs(currentOutfit.hiddenSlots) do
                if hidden then
                    hiddenSlots[slot] = true
                end
            end
        end
    end
    
    return {
        equippedItems = equippedItems,
        lockedSlots = lockedSlots,
        hiddenSlots = hiddenSlots,
        outfit = currentOutfit
    }
end

exports("isClothingSlotLocked", function(...) return CubXAppearance.IsLocked(...) end)
exports("getEquippedAccessories", function(...) return CubXAppearance.GetEquipped(...) end)
exports("getLockedClothingSlots", function(...) return CubXAppearance.GetLockedSlots(...) end)
exports("applyAppearance", function(...) return CubXAppearance.Apply(...) end)
exports("removeAppearance", function(...) return CubXAppearance.Remove(...) end)
exports("restoreAppearance", function(...) return CubXAppearance.RestoreAll(...) end)
exports("addEquippedAccessory", function(...) return CubXAppearance.AddEquipped(...) end)
exports("removeEquippedAccessory", function(...) return CubXAppearance.RemoveEquipped(...) end)
exports("setCurrentOutfit", function(...) return CubXAppearance.SetCurrentOutfit(...) end)
exports("setLockedSlots", function(...) return CubXAppearance.SetLockedSlots(...) end)
exports("getEquippedForNUI", function(...) return CubXAppearance.GetEquippedForNUI(...) end)
exports("handleToggleClothingVisibility", function(...) return CubXAppearance.HandleToggleClothingVisibility(...) end)
exports("handleUnequipClothing", function(...) return CubXAppearance.HandleUnequipClothing(...) end)
exports("handleUnequipOutfit", function(...) return CubXAppearance.HandleUnequipOutfit(...) end)
exports("equipClothingItem", function(...) return CubXAppearance.EquipClothingItem(...) end)
exports("equipOutfitItem", function(...) return CubXAppearance.EquipOutfitItem(...) end)