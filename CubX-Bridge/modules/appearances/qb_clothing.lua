--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local Appearance = {}

function Appearance.Initialize()
    if GetResourceState("qb-clothing") ~= "started" then
        CBUX.Utils.Error("qb-clothing not started!")
        return false
    end
    CBUX.Utils.Debug("qb-clothing module initialized")
    return true
end

local componentsMapping = {
    [1] = "mask",
    [2] = "hair",
    [3] = "arms",
    [4] = "pants",
    [5] = "bag",
    [6] = "shoes",
    [7] = "accessory",
    [8] = "t-shirt",
    [9] = "vest",
    [10] = "decals",
    [11] = "torso2"
}

local propsMapping = {
    [0] = "hat",
    [1] = "glass",
    [2] = "ear",
    [6] = "watch",
    [7] = "bracelet"
}

local headOverlaysMapping = {
    [1] = "beard",
    [2] = "eyebrows",
    [3] = "ageing",
    [4] = "makeup",
    [5] = "blush",
    [8] = "lipstick",
    [9] = "moles"
}

local faceFeaturesMapping = {
    [0] = "nose_0",
    [1] = "nose_1",
    [2] = "nose_2",
    [3] = "nose_3",
    [4] = "nose_4",
    [5] = "nose_5",
    [6] = "cheek_1",
    [7] = "cheek_2",
    [8] = "cheek_3",
    [9] = "eye_opening",
    [10] = "lips_thickness",
    [11] = "jaw_bone_width",
    [12] = "eyebrown_high",
    [13] = "eyebrown_forward",
    [14] = "jaw_bone_back_lenght",
    [15] = "chimp_bone_lowering",
    [16] = "chimp_bone_lenght",
    [17] = "chimp_bone_width",
    [18] = "chimp_hole",
    [19] = "neck_thikness"
}

local function safeNumber(val, default)
    return tonumber(val) or default
end

function Appearance.ToUnified(qbClothing)
    if not qbClothing then return nil end
    
    local model = qbClothing.__model or 1885233650
    local unified = {
        model = model,
        components = {},
        props = {},
        headOverlays = {}
    }
    
    unified.hair = {
        style = qbClothing.hair and safeNumber(qbClothing.hair.item, 0) or 0,
        color = qbClothing.hair and safeNumber(qbClothing.hair.texture, 0) or 0,
        highlight = qbClothing.hair and safeNumber(qbClothing.hair.texture, 0) or 0 -- qb-clothing doesn't have highlight?
    }
    
    unified.eyeColor = qbClothing.eye_color and safeNumber(qbClothing.eye_color.item, 0) or 0
    unified._raw = qbClothing
    
    for compId, key in pairs(componentsMapping) do
        if qbClothing[key] then
            unified.components[compId] = {
                drawable = safeNumber(qbClothing[key].item, 0),
                texture = safeNumber(qbClothing[key].texture, 0)
            }
        end
    end
    
    for propId, key in pairs(propsMapping) do
        if qbClothing[key] then
            local drawable = safeNumber(qbClothing[key].item, -1)
            if drawable == 0 then drawable = -1 end
            unified.props[propId] = {
                drawable = drawable,
                texture = safeNumber(qbClothing[key].texture, 0)
            }
        end
    end
    
    for overlayId, key in pairs(headOverlaysMapping) do
        if qbClothing[key] then
            unified.headOverlays[overlayId] = {
                index = safeNumber(qbClothing[key].item, 255),
                opacity = safeNumber(qbClothing[key].texture, 0) / 10.0,
                colorType = 0,
                firstColor = 0,
                secondColor = 0
            }
        end
    end
    
    if qbClothing.face and qbClothing.face2 and qbClothing.facemix then
        unified.headBlend = {
            shapeFirst = safeNumber(qbClothing.face.item, 0),
            shapeSecond = safeNumber(qbClothing.face2.item, 0),
            shapeThird = 0,
            skinFirst = safeNumber(qbClothing.face.texture, 0),
            skinSecond = safeNumber(qbClothing.face2.texture, 0),
            skinThird = 0,
            shapeMix = safeNumber(qbClothing.facemix.shapeMix, 0.5),
            skinMix = safeNumber(qbClothing.facemix.skinMix, 0.5),
            thirdMix = 0.0
        }
    end
    
    unified.faceFeatures = {}
    for featureId, key in pairs(faceFeaturesMapping) do
        unified.faceFeatures[featureId] = qbClothing[key] and (safeNumber(qbClothing[key].item, 0) / 10.0) or 0.0
    end
    
    return unified
end

function Appearance.FromUnified(unified)
    if not unified then return nil end
    local qbClothing = {}
    
    for compId, key in pairs(componentsMapping) do
        local comp = unified.components and unified.components[compId]
        qbClothing[key] = {
            item = comp and (comp.drawable or 0) or 0,
            texture = comp and (comp.texture or 0) or 0,
            defaultItem = 0,
            defaultTexture = 0
        }
    end
    
    for propId, key in pairs(propsMapping) do
        local prop = unified.props and unified.props[propId]
        qbClothing[key] = {
            item = prop and (prop.drawable or -1) or -1,
            texture = prop and (prop.texture or 0) or 0,
            defaultItem = -1,
            defaultTexture = 0
        }
    end
    
    if unified.hair then
        qbClothing.hair = {
            item = unified.hair.style or 0,
            texture = unified.hair.color or 0,
            defaultItem = 0,
            defaultTexture = 0
        }
    end
    
    qbClothing.eye_color = {
        item = unified.eyeColor or 0,
        defaultItem = 0
    }
    
    for overlayId, key in pairs(headOverlaysMapping) do
        local overlay = unified.headOverlays and unified.headOverlays[overlayId]
        qbClothing[key] = {
            item = overlay and (overlay.index or 0) or 0,
            texture = overlay and math.floor((overlay.opacity or 0) * 10) or 0,
            defaultItem = 0,
            defaultTexture = 0
        }
    end
    
    if unified.headBlend then
        qbClothing.face = {
            item = unified.headBlend.shapeFirst or 0,
            texture = unified.headBlend.skinFirst or 0,
            defaultItem = 0,
            defaultTexture = 0
        }
        qbClothing.face2 = {
            item = unified.headBlend.shapeSecond or 0,
            texture = unified.headBlend.skinSecond or 0,
            defaultItem = 0,
            defaultTexture = 0
        }
        qbClothing.facemix = {
            shapeMix = unified.headBlend.shapeMix or 0.5,
            skinMix = unified.headBlend.skinMix or 0.5,
            defaultShapeMix = 0.5,
            defaultSkinMix = 0.5
        }
    end
    
    if unified.faceFeatures then
        for featureId, key in pairs(faceFeaturesMapping) do
            qbClothing[key] = {
                item = math.floor((unified.faceFeatures[featureId] or 0) * 10),
                defaultItem = 0
            }
        end
    end
    
    return qbClothing
end

if IsDuplicityVersion() then
    function Appearance.GetPlayerAppearance(playerId)
        local player = exports["CubX-Bridge"]:GetPlayer(playerId)
        if not player or not player.identifier then
            return nil
        end
        
        local result = exports.oxmysql:query_async("SELECT model, skin FROM playerskins WHERE citizenid = ? AND active = 1 LIMIT 1", {player.identifier})
        if not result or not result[1] then
            return nil
        end
        
        local success, decodedSkin = pcall(json.decode, result[1].skin)
        if not success or not decodedSkin then
            return nil
        end
        
        decodedSkin.__model = tonumber(result[1].model)
        return Appearance.ToUnified(decodedSkin)
    end
    
    function Appearance.SetPlayerAppearance(playerId, appearance)
        if not appearance then
            return false
        end
        local qbClothing = Appearance.FromUnified(appearance)
        TriggerClientEvent(Config.EventPrefix .. ":client:setAppearance", playerId, qbClothing)
        return true
    end
    
    function Appearance.SaveAppearance(playerId, appearance)
        if not appearance then
            TriggerClientEvent(Config.EventPrefix .. ":client:saveAppearance", playerId, nil)
            return
        end
        
        local player = exports["CubX-Bridge"]:GetPlayer(playerId)
        if not player or not player.identifier then
            return
        end
        
        local qbClothing = Appearance.FromUnified(appearance)
        local model = appearance.model
        if type(model) == "string" then
            model = joaat(model)
        end
        if not model then
            model = 1885233650
        end
        
        local encodedSkin = json.encode(qbClothing)
        
        exports.oxmysql:execute_async("DELETE FROM playerskins WHERE citizenid = ?", {player.identifier})
        exports.oxmysql:insert_async("INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, 1)", {player.identifier, tostring(model), encodedSkin})
        
        TriggerClientEvent("qb-clothes:loadSkin", playerId, false, tostring(model), encodedSkin)
    end
else
    function Appearance.GetPedAppearance(ped)
        if not ped then ped = PlayerPedId() end
        return Appearance.GetPedAppearanceNative(ped)
    end
    
    function Appearance.SetPedAppearance(ped, appearance)
        if not appearance then return end
        if not ped then ped = PlayerPedId() end
        
        local qbClothing = Appearance.FromUnified(appearance)
        TriggerEvent("qb-clothing:client:loadPlayerClothing", qbClothing, ped)
    end
    
    function Appearance.SetAppearanceFromServer(appearance)
        if not appearance then return end
        
        local qbClothing = appearance
        if appearance.components then
            qbClothing = Appearance.FromUnified(appearance) or appearance
        end
        
        TriggerEvent("qb-clothing:client:loadPlayerClothing", qbClothing, PlayerPedId())
    end
    
    function Appearance.SaveAppearance(appearance)
        local qbClothing = nil
        if appearance and appearance.components then
            qbClothing = Appearance.FromUnified(appearance)
        elseif appearance then
            qbClothing = appearance
        else
            qbClothing = Appearance.FromUnified(Appearance.GetPedAppearanceNative(PlayerPedId()))
        end
        
        local model = GetEntityModel(PlayerPedId())
        TriggerServerEvent("qb-clothing:saveSkin", tostring(model), json.encode(qbClothing))
    end
    
    function Appearance.SetPedComponent(ped, componentId, drawableId, textureId)
        if not ped then ped = PlayerPedId() end
        SetPedComponentVariation(ped, componentId, drawableId, textureId, 0)
    end
    
    function Appearance.SetPedProp(ped, propId, drawableId, textureId)
        if not ped then ped = PlayerPedId() end
        if drawableId == -1 then
            ClearPedProp(ped, propId)
        else
            SetPedPropIndex(ped, propId, drawableId, textureId, true)
        end
    end
    
    function Appearance.SetPedHair(ped, hairId, color1, color2)
        if not ped then ped = PlayerPedId() end
        SetPedComponentVariation(ped, 2, hairId, 0, 0)
        SetPedHairColor(ped, color1 or 0, color2 or 0)
    end
    
    function Appearance.SetPedHeadOverlay(ped, overlayId, index, opacity, color1, color2)
        if not ped then ped = PlayerPedId() end
        SetPedHeadOverlay(ped, overlayId, index, opacity or 1.0)
        if color1 and color2 then
            SetPedHeadOverlayColor(ped, overlayId, color1, color2, color2 or color1)
        end
    end
    
    function Appearance.SetPedEyeColor(ped, index)
        if not ped then ped = PlayerPedId() end
        SetPedEyeColor(ped, index)
    end
    
    function Appearance.GetPedModel(ped)
        if not ped then ped = PlayerPedId() end
        return GetEntityModel(ped)
    end
    
    function Appearance.SetPedModel(ped, model)
        if type(model) == "string" then
            model = joaat(model)
        end
        RequestModel(model)
        local timeout = 500
        while not HasModelLoaded(model) and timeout > 0 do
            Wait(10)
            timeout = timeout - 1
        end
        if HasModelLoaded(model) then
            SetPlayerModel(PlayerId(), model)
            SetModelAsNoLongerNeeded(model)
        end
    end
    
    function Appearance.GetPedAppearanceNative(ped)
        if not ped then ped = PlayerPedId() end
        local appearance = {
            components = {},
            props = {},
            headOverlays = {}
        }
        
        for i = 0, 11 do
            appearance.components[i] = {
                drawable = GetPedDrawableVariation(ped, i),
                texture = GetPedTextureVariation(ped, i)
            }
        end
        
        for i = 0, 9 do
            appearance.props[i] = {
                drawable = GetPedPropIndex(ped, i),
                texture = GetPedPropTextureIndex(ped, i)
            }
        end
        
        for i = 0, 12 do
            local success, value, colorType, firstColor, secondColor, opacity = GetPedHeadOverlayData(ped, i)
            appearance.headOverlays[i] = {
                index = value,
                opacity = opacity,
                colorType = colorType,
                firstColor = firstColor,
                secondColor = secondColor
            }
        end
        
        appearance.model = GetEntityModel(ped)
        appearance.hair = {
            style = GetPedDrawableVariation(ped, 2),
            color = GetPedHairColor(ped),
            highlight = GetPedHairHighlightColor(ped)
        }
        appearance.eyeColor = GetPedEyeColor(ped)
        
        return appearance
    end
end

CBUX.RegisterModule("appearances", "qb-clothing", Appearance)