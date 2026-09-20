local provider = {
    name = 'native',
    capabilities = {
        snapshot = true,
        components = true,
        props = true,
        hair = true,
        faceFeatures = true,
        overlays = true,
        model = true,
        wardrobe = true,
        persistence = false,
    },
}

function provider:get(ped)
    return ViceCityAppearanceNativeSnapshot(ped)
end

function provider:getRaw(ped)
    return self:get(ped)
end

function provider:set(ped, appearance)
    if ViceCityConfig.appearance.applyMode ~= 'provider' then
        return ViceCityAppearanceApplyNative(ped, appearance)
    end
    return false, { reason = 'provider_unavailable', provider = self.name }
end

function provider:getComponent(ped, component)
    ped = ViceCityAppearanceDefaultPed(ped)
    return {
        drawable = GetPedDrawableVariation(ped, component),
        texture = GetPedTextureVariation(ped, component),
        palette = GetPedPaletteVariation(ped, component),
    }
end

function provider:setComponent(ped, component, drawable, texture, palette)
    SetPedComponentVariation(ViceCityAppearanceDefaultPed(ped), component, drawable, texture or 0, palette or 0)
    return true
end

function provider:getProp(ped, prop)
    ped = ViceCityAppearanceDefaultPed(ped)
    return { drawable = GetPedPropIndex(ped, prop), texture = GetPedPropTextureIndex(ped, prop) }
end

function provider:setProp(ped, prop, drawable, texture)
    ped = ViceCityAppearanceDefaultPed(ped)
    if drawable == nil or drawable < 0 then
        ClearPedProp(ped, prop)
    else
        SetPedPropIndex(ped, prop, drawable, texture or 0, true)
    end
    return true
end

function provider:getHair(ped)
    ped = ViceCityAppearanceDefaultPed(ped)
    return {
        style = GetPedDrawableVariation(ped, 2),
        color = GetPedHairColor(ped),
        highlight = GetPedHairHighlightColor(ped),
    }
end

function provider:setHair(ped, hair)
    ped = ViceCityAppearanceDefaultPed(ped)
    SetPedComponentVariation(ped, 2, hair.style or 0, hair.texture or 0, 0)
    SetPedHairColor(ped, hair.color or 0, hair.highlight or 0)
    return true
end

function provider:setModel(model, appearance)
    model = ViceCityAppearanceModelHash(model)
    if not model then return false, { reason = 'invalid_model' } end
    RequestModel(model)
    local deadline = GetGameTimer() + (ViceCityConfig.providerTimeout or 5000)
    while not HasModelLoaded(model) and GetGameTimer() < deadline do Wait(0) end
    if not HasModelLoaded(model) then return false, { reason = 'model_timeout' } end
    SetPlayerModel(PlayerId(), model)
    SetModelAsNoLongerNeeded(model)
    if appearance then ViceCityAppearanceApplyNative(PlayerPedId(), appearance) end
    TriggerEvent('vicecity:appearance:modelChanged', model)
    return true
end

function provider:save() return false, { reason = 'unsupported', operation = 'save', provider = self.name } end

function provider:load() return self:get() end

function provider:openWardrobe() return false,
        { reason = 'unsupported', operation = 'openWardrobe', provider = self.name } end

ViceCity.RegisterProvider('appearance', 'native', provider)
