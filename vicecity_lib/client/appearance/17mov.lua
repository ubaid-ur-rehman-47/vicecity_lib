local provider = {
    name = '17mov',
    resource = '17mov_CharacterSystem',
    capabilities = {
        snapshot = true,
        components = true,
        props = true,
        hair = true,
        faceFeatures = true,
        overlays = true,
        model = true,
        wardrobe = true,
        persistence = true,
    },
}

local function illenium()
    if GetResourceState('illenium-appearance') ~= 'started' then return nil end
    return exports['illenium-appearance']
end

function provider:get(ped)
    local appearance = illenium()
    if appearance and appearance.getPedAppearance then
        local ok, value = pcall(function() return appearance:getPedAppearance(ped or PlayerPedId()) end)
        if ok and value then return value end
    end
    return ViceCityAppearanceNativeSnapshot(ped)
end

function provider:getRaw(ped)
    return self:get(ped)
end

function provider:set(ped, data)
    local appearance = illenium()
    if appearance and appearance.setPedAppearance and ViceCityConfig.appearance.applyMode ~= 'native' then
        local ok = pcall(function() appearance:setPedAppearance(ped or PlayerPedId(), data) end)
        if ok then return true end
    end
    return ViceCityAppearanceApplyNative(ped, data)
end

function provider:getComponent(ped, component)
    local appearance = self:get(ped)
    return appearance and appearance.components and appearance.components[component]
        or ViceCityAppearanceNativeSnapshot(ped).components[component]
end

function provider:setComponent(ped, component, drawable, texture, palette)
    SetPedComponentVariation(ped or PlayerPedId(), component, drawable, texture or 0, palette or 0)
    return true
end

function provider:getProp(ped, prop)
    local appearance = self:get(ped)
    return appearance and appearance.props and appearance.props[prop]
        or ViceCityAppearanceNativeSnapshot(ped).props[prop]
end

function provider:setProp(ped, prop, drawable, texture)
    ped = ped or PlayerPedId()
    if drawable == nil or drawable < 0 then
        ClearPedProp(ped, prop)
    else
        SetPedPropIndex(ped, prop, drawable, texture or 0, true)
    end
    return true
end

function provider:getHair(ped)
    local appearance = self:get(ped)
    return appearance and appearance.hair or ViceCityAppearanceNativeSnapshot(ped).hair
end

function provider:setHair(ped, hair)
    ped = ped or PlayerPedId()
    SetPedComponentVariation(ped, 2, hair.style or 0, hair.texture or 0, 0)
    SetPedHairColor(ped, hair.color or 0, hair.highlight or 0)
    return true
end

function provider:setModel(model, appearance)
    local native = ViceCity.Providers.appearance.native
    return native and native.setModel(native, model, appearance)
end

function provider:save()
    TriggerEvent('17mov_CharacterSystem:SaveCurrentSkin')
    return true
end

function provider:load()
    return self:get()
end

function provider:openWardrobe()
    TriggerEvent('17mov_CharacterSystem:OpenOutfitsMenu')
    return true
end

function provider:saveOutfit()
    return self:save()
end

ViceCity.RegisterProvider('appearance', '17mov', provider)
