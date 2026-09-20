--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

function GetAppearanceSystemFn(funcName)
    if CBUX.Modules.Appearance then
        if CBUX.Modules.Appearance[funcName] then
            return CBUX.Modules.Appearance[funcName]
        end
    end
    return nil
end

function GetPedAppearance(ped)
    if not CBUX.Ready then
        return {}
    end
    local fn = GetAppearanceSystemFn("GetPedAppearance")
    if fn then
        return fn(ped)
    end
    CBUX.Utils.Warn("GetPedAppearance: No appearance system available")
    return {}
end

function SetPedAppearance(ped, appearanceData)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedAppearance")
    if fn then
        return fn(ped, appearanceData)
    end
    CBUX.Utils.Warn("SetPedAppearance: No appearance system available")
end

function SetPedComponent(ped, componentId, drawableId, textureId)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedComponent")
    if fn then
        return fn(ped, componentId, drawableId, textureId)
    end
    if not ped then
        ped = PlayerPedId()
    end
    SetPedComponentVariation(ped, componentId, drawableId, textureId, 0)
end

function GetPedComponent(ped, componentId)
    if not CBUX.Ready then
        return { drawable = 0, texture = 0 }
    end
    if not ped then
        ped = PlayerPedId()
    end
    local comp = {}
    comp.drawable = GetPedDrawableVariation(ped, componentId)
    comp.texture = GetPedTextureVariation(ped, componentId)
    return comp
end

function SetPedProp(ped, componentId, drawableId, textureId)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedProp")
    if fn then
        return fn(ped, componentId, drawableId, textureId)
    end
    if not ped then
        ped = PlayerPedId()
    end
    if drawableId == -1 then
        ClearPedProp(ped, componentId)
    else
        SetPedPropIndex(ped, componentId, drawableId, textureId, true)
    end
end

function GetPedProp(ped, componentId)
    if not CBUX.Ready then
        return { drawable = -1, texture = 0 }
    end
    if not ped then
        ped = PlayerPedId()
    end
    local prop = {}
    prop.drawable = GetPedPropIndex(ped, componentId)
    prop.texture = GetPedPropTextureIndex(ped, componentId)
    return prop
end

function SetPedHair(ped, drawableId, textureId, highlightColor)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedHair")
    if fn then
        return fn(ped, drawableId, textureId, highlightColor)
    end
    if not ped then
        ped = PlayerPedId()
    end
    SetPedComponentVariation(ped, 2, drawableId, 0, 0)
    SetPedHairColor(ped, textureId or 0, highlightColor or 0)
end

function GetPedHair(ped)
    if not CBUX.Ready then
        return { style = 0, color = 0, highlight = 0 }
    end
    if not ped then
        ped = PlayerPedId()
    end
    local hair = {}
    hair.style = GetPedDrawableVariation(ped, 2)
    hair.color = GetPedHairColor(ped)
    hair.highlight = GetPedHairHighlightColor(ped)
    return hair
end

function SetPedHeadOverlay(ped, overlayID, index, opacity, colorType, firstColor, secondColor)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedHeadOverlay")
    if fn then
        return fn(ped, overlayID, index, opacity, colorType, firstColor, secondColor)
    end
    if not ped then
        ped = PlayerPedId()
    end
    SetPedHeadOverlay(ped, overlayID, index, opacity or 1.0)
    if colorType and firstColor then
        SetPedHeadOverlayColor(ped, overlayID, colorType, firstColor, secondColor or firstColor)
    end
end

function GetPedHeadOverlayDataCbux(ped, overlayID)
    if not CBUX.Ready then
        return { index = 255, opacity = 1.0 }
    end
    if not ped then
        ped = PlayerPedId()
    end
    local _, index, colorType, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, overlayID)
    return {
        index = index,
        opacity = opacity,
        colorType = colorType,
        firstColor = firstColor,
        secondColor = secondColor
    }
end

function SetPedEyeColorCbux(ped, index)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedEyeColor")
    if fn then
        return fn(ped, index)
    end
    if not ped then
        ped = PlayerPedId()
    end
    SetPedEyeColor(ped, index)
end

function GetPedEyeColorCbux(ped)
    if not CBUX.Ready then
        return 0
    end
    if not ped then
        ped = PlayerPedId()
    end
    return GetPedEyeColor(ped)
end

function GetPedModelCbux(ped)
    if not CBUX.Ready then
        return 0
    end
    if not ped then
        ped = PlayerPedId()
    end
    return GetEntityModel(ped)
end

function SetPedModelCbux(ped, modelHash)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetPedModel")
    if fn then
        return fn(nil, modelHash)
    end
    local model = modelHash
    if type(modelHash) == "string" then
        model = joaat(modelHash) or modelHash
    end
    RequestModel(model)
    local waitTime = 500
    while not HasModelLoaded(model) and waitTime > 0 do
        Wait(10)
        waitTime = waitTime - 1
    end
    if HasModelLoaded(model) then
        SetPlayerModel(PlayerId(), model)
        SetModelAsNoLongerNeeded(model)
    end
end

function GetComponentDrawableCount(ped, componentId)
    if not ped then
        ped = PlayerPedId()
    end
    return GetNumberOfPedDrawableVariations(ped, componentId)
end

function GetComponentTextureCount(ped, componentId, drawableId)
    if not ped then
        ped = PlayerPedId()
    end
    return GetNumberOfPedTextureVariations(ped, componentId, drawableId)
end

function GetPropDrawableCount(ped, propId)
    if not ped then
        ped = PlayerPedId()
    end
    return GetNumberOfPedPropDrawableVariations(ped, propId)
end

function GetPropTextureCount(ped, propId, drawableId)
    if not ped then
        ped = PlayerPedId()
    end
    return GetNumberOfPedPropTextureVariations(ped, propId, drawableId)
end

function GetAppearanceSystem()
    return CBUX.Appearance
end

RegisterNetEvent(Config.EventPrefix .. ":client:saveAppearance", function(appearanceData)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SaveAppearance")
    if fn then
        return fn(appearanceData)
    end
    CBUX.Utils.Warn("SaveAppearance: No appearance system available")
end)

RegisterNetEvent(Config.EventPrefix .. ":client:setAppearance", function(appearanceData)
    if not CBUX.Ready then
        return
    end
    local fn = GetAppearanceSystemFn("SetAppearanceFromServer")
    if fn then
        return fn(appearanceData)
    end
    CBUX.Utils.Warn("SetAppearanceFromServer: No appearance system available")
end)

exports("GetPedAppearance", GetPedAppearance)
exports("SetPedAppearance", SetPedAppearance)
exports("SetPedComponent", SetPedComponent)
exports("GetPedComponent", GetPedComponent)
exports("SetPedProp", SetPedProp)
exports("GetPedProp", GetPedProp)
exports("SetPedHair", SetPedHair)
exports("GetPedHair", GetPedHair)
exports("SetPedHeadOverlay", SetPedHeadOverlay)
exports("GetPedHeadOverlay", GetPedHeadOverlayDataCbux)
exports("SetPedEyeColor", SetPedEyeColorCbux)
exports("GetPedEyeColor", GetPedEyeColorCbux)
exports("GetPedModel", GetPedModelCbux)
exports("SetPedModel", SetPedModelCbux)
exports("GetComponentDrawableCount", GetComponentDrawableCount)
exports("GetComponentTextureCount", GetComponentTextureCount)
exports("GetPropDrawableCount", GetPropDrawableCount)
exports("GetPropTextureCount", GetPropTextureCount)
exports("GetAppearanceSystem", GetAppearanceSystem)