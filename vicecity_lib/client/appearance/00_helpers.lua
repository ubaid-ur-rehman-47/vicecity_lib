local function defaultPed(ped)
    return ped or PlayerPedId()
end

local function modelHash(model)
    return type(model) == 'string' and joaat(model) or model
end

local function nativeSnapshot(ped)
    ped = defaultPed(ped)
    local appearance = {
        model = GetEntityModel(ped),
        components = {},
        props = {},
        overlays = {},
        faceFeatures = {},
        headBlend = {},
        hair = {
            style = GetPedDrawableVariation(ped, 2),
            color = GetPedHairColor(ped),
            highlight = GetPedHairHighlightColor(ped),
        },
        eyeColor = GetPedEyeColor(ped),
    }

    for component = 0, 11 do
        appearance.components[component] = {
            drawable = GetPedDrawableVariation(ped, component),
            texture = GetPedTextureVariation(ped, component),
            palette = GetPedPaletteVariation(ped, component),
        }
    end
    for prop = 0, 7 do
        appearance.props[prop] = {
            drawable = GetPedPropIndex(ped, prop),
            texture = GetPedPropTextureIndex(ped, prop),
        }
    end
    for feature = 0, 19 do
        appearance.faceFeatures[feature] = GetPedFaceFeature(ped, feature)
    end
    for overlay = 0, 12 do
        local exists, index, colorType, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, overlay)
        if exists then
            appearance.overlays[overlay] = {
                index = index,
                opacity = opacity,
                colorType = colorType,
                firstColor = firstColor,
                secondColor = secondColor,
            }
        end
    end

    return appearance
end

local function applyNative(ped, appearance)
    ped = defaultPed(ped)
    if type(appearance) ~= 'table' then return false end

    if appearance.headBlend and next(appearance.headBlend) then
        local blend = appearance.headBlend
        SetPedHeadBlendData(ped, blend.shapeFirst or 0, blend.shapeSecond or 0, blend.shapeThird or 0,
            blend.skinFirst or 0, blend.skinSecond or 0, blend.skinThird or 0,
            blend.shapeMix or 0.0, blend.skinMix or 0.0, blend.thirdMix or 0.0, false)
    end
    for component, data in pairs(appearance.components or {}) do
        local componentId = tonumber(component) or 0
        SetPedComponentVariation(ped, componentId, data.drawable or 0, data.texture or 0, data.palette or 0)
    end
    for prop, data in pairs(appearance.props or {}) do
        prop = tonumber(prop) or 0
        if (data.drawable or -1) < 0 then
            ClearPedProp(ped, prop)
        else
            SetPedPropIndex(ped, prop, data.drawable, data.texture or 0, true)
        end
    end
    if appearance.hair then
        SetPedComponentVariation(ped, 2, appearance.hair.style or 0, appearance.hair.texture or 0, 0)
        SetPedHairColor(ped, appearance.hair.color or 0, appearance.hair.highlight or 0)
    end
    for feature, value in pairs(appearance.faceFeatures or {}) do
        SetPedFaceFeature(ped, tonumber(feature) or 0, value)
    end
    for overlay, data in pairs(appearance.overlays or {}) do
        overlay = tonumber(overlay) or 0
        SetPedHeadOverlay(ped, overlay, data.index or 255, data.opacity or 0.0)
        if data.colorType then
            SetPedHeadOverlayColor(ped, overlay, data.colorType, data.firstColor or 0, data.secondColor or 0)
        end
    end
    if appearance.eyeColor then SetPedEyeColor(ped, appearance.eyeColor) end
    return true
end

ViceCityAppearanceDefaultPed = defaultPed
ViceCityAppearanceModelHash = modelHash
ViceCityAppearanceNativeSnapshot = nativeSnapshot
ViceCityAppearanceApplyNative = applyNative
