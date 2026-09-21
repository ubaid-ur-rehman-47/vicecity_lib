-- Clothing slot visibility toggle: click a clothing icon in the inventory UI
-- to hide/show that piece of the player's currently worn appearance.
-- No inventory items are involved; clothing is never consumed or given here.
if not lib then return end

local ViceCity = exports.vicecity_lib

-- Slot-key naming used by this inventory's NUI, mapped to ped component/prop ids.
local slotComponents = {
    mask = 1,
    arms = 3,
    legs = 4,
    bag = 5,
    shoes = 6,
    necklace = 7,
    undershirt = 8,
    armor = 9,
    decals = 10,
    torso = 11,
}

local slotProps = {
    hat = 0,
    glasses = 1,
    ears = 2,
    watch = 6,
    bracelet = 7,
}

local hiddenSlots = {}
local originalAppearance

local function captureOriginalAppearance()
    if originalAppearance then return end

    local ok, appearance = pcall(function() return ViceCity:GetAppearance(cache.ped) end)
    if ok and appearance then
        originalAppearance = appearance
    end
end

local function restoreComponent(componentId)
    local drawable, texture

    if originalAppearance and originalAppearance.components and originalAppearance.components[componentId] then
        local comp = originalAppearance.components[componentId]
        drawable, texture = comp.drawable, comp.texture
    else
        local ok, comp = pcall(function() return ViceCity:GetAppearanceComponent(cache.ped, componentId) end)
        if not ok or not comp then return end
        drawable, texture = comp.drawable, comp.texture
    end

    ViceCity:SetAppearanceComponent(cache.ped, componentId, drawable, texture)
end

local function restoreProp(propId)
    local drawable, texture

    if originalAppearance and originalAppearance.props and originalAppearance.props[propId] then
        local prop = originalAppearance.props[propId]
        drawable, texture = prop.drawable, prop.texture
    else
        local ok, prop = pcall(function() return ViceCity:GetAppearanceProp(cache.ped, propId) end)
        if not ok or not prop then return end
        drawable, texture = prop.drawable, prop.texture
    end

    ViceCity:SetAppearanceProp(cache.ped, propId, drawable, texture)
end

local function hideComponent(componentId)
    local default = ViceCity:GetDefaultAppearanceComponent(cache.ped, componentId)
    if not default then return end

    ViceCity:SetAppearanceComponent(cache.ped, componentId, default.drawable, default.texture)
end

local function hideProp(propId)
    local default = ViceCity:GetDefaultAppearanceProp(cache.ped, propId)
    ViceCity:SetAppearanceProp(cache.ped, propId, default and default.drawable or -1, default and default.texture or 0)
end

local function toggleClothingVisibility(slotKey, hidden)
    local componentId = slotComponents[slotKey]
    local propId = slotProps[slotKey]

    if not componentId and not propId then return false end

    captureOriginalAppearance()

    if hidden then
        if componentId then hideComponent(componentId) else hideProp(propId) end
    else
        if componentId then restoreComponent(componentId) else restoreProp(propId) end
    end

    hiddenSlots[slotKey] = hidden or nil

    return true
end

Clothing = {
    ToggleClothingVisibility = toggleClothingVisibility,
    CaptureOriginalAppearance = captureOriginalAppearance,
    GetHiddenSlots = function() return hiddenSlots end,
}
