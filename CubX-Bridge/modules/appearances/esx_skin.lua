--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local Appearance = {}

function Appearance.Initialize()
    if GetResourceState("esx_skin") ~= "started" then
        CBUX.Utils.Error("esx_skin not started!")
        return false
    end
    CBUX.Utils.Debug("esx_skin module initialized")
    return true
end

local componentsMapping = {
    [0] = {drawable = "face", texture = nil},
    [1] = {drawable = "mask_1", texture = "mask_2"},
    [2] = {drawable = "hair_1", texture = "hair_2"},
    [3] = {drawable = "arms", texture = "arms_2"},
    [4] = {drawable = "pants_1", texture = "pants_2"},
    [5] = {drawable = "bags_1", texture = "bags_2"},
    [6] = {drawable = "shoes_1", texture = "shoes_2"},
    [7] = {drawable = "chain_1", texture = "chain_2"},
    [8] = {drawable = "tshirt_1", texture = "tshirt_2"},
    [9] = {drawable = "bproof_1", texture = "bproof_2"},
    [10] = {drawable = "decals_1", texture = "decals_2"},
    [11] = {drawable = "torso_1", texture = "torso_2"}
}

local propsMapping = {
    [0] = {drawable = "helmet_1", texture = "helmet_2"},
    [1] = {drawable = "glasses_1", texture = "glasses_2"},
    [2] = {drawable = "ears_1", texture = "ears_2"},
    [6] = {drawable = "watches_1", texture = "watches_2"},
    [7] = {drawable = "bracelets_1", texture = "bracelets_2"}
}

local headOverlaysMapping = {
    [0] = {index = "blemishes_1", opacity = "blemishes_2"},
    [1] = {index = "beard_3", opacity = "beard_4"},
    [2] = {index = "eyebrows_1", opacity = "eyebrows_2"},
    [3] = {index = "age_1", opacity = "age_2"},
    [4] = {index = "makeup_1", opacity = "makeup_2"},
    [5] = {index = "blush_1", opacity = "blush_2"},
    [6] = {index = "complexion_1", opacity = "complexion_2"},
    [7] = {index = "sun_1", opacity = "sun_2"},
    [8] = {index = "lipstick_1", opacity = "lipstick_2"},
    [9] = {index = "moles_1", opacity = "moles_2"},
    [10] = {index = "chest_1", opacity = "chest_2"},
    [11] = {index = "bodyb_1", opacity = "bodyb_2"}
}

local faceFeaturesMapping = {
    [1] = "nose_1",
    [2] = "nose_2",
    [3] = "nose_3",
    [4] = "nose_4",
    [5] = "nose_5",
    [6] = "nose_6",
    [7] = "cheeks_1",
    [8] = "cheeks_2",
    [9] = "cheeks_3",
    [10] = "lip_thickness",
    [11] = "jaw_1",
    [12] = "jaw_2",
    [13] = "chin_1",
    [14] = "chin_2",
    [15] = "chin_3",
    [16] = "neck_thickness",
    [17] = "eyebrows_5",
    [18] = "eyebrows_6",
    [19] = "eye_squint",
    [20] = "chin_4"
}

function Appearance.ToUnified(esxSkin)
    if not esxSkin then return nil end
    local unified = {}
    
    if esxSkin.sex == 0 then
        unified.model = 1885233650
    else
        unified.model = -1667301416
    end
    
    unified.components = {}
    unified.props = {}
    unified.headOverlays = {}
    
    unified.hair = {
        style = tonumber(esxSkin.hair_1) or 0,
        color = tonumber(esxSkin.hair_color_1) or 0,
        highlight = tonumber(esxSkin.hair_color_2) or 0
    }
    
    unified.eyeColor = tonumber(esxSkin.eye_color) or 0
    unified._raw = esxSkin
    
    for compId, keys in pairs(componentsMapping) do
        unified.components[compId] = {
            drawable = tonumber(esxSkin[keys.drawable]) or 0,
            texture = keys.texture and (tonumber(esxSkin[keys.texture]) or 0) or 0
        }
    end
    
    for propId, keys in pairs(propsMapping) do
        unified.props[propId] = {
            drawable = tonumber(esxSkin[keys.drawable]) or -1,
            texture = tonumber(esxSkin[keys.texture]) or 0
        }
    end
    
    for overlayId, keys in pairs(headOverlaysMapping) do
        if esxSkin[keys.index] ~= nil then
            unified.headOverlays[overlayId] = {
                index = tonumber(esxSkin[keys.index]) or 255,
                opacity = tonumber(esxSkin[keys.opacity]) or 1.0,
                colorType = 0,
                firstColor = 0,
                secondColor = 0
            }
        end
    end
    
    if esxSkin.mom ~= nil then
        unified.headBlend = {
            shapeFirst = tonumber(esxSkin.mom) or 0,
            shapeSecond = tonumber(esxSkin.dad) or 0,
            shapeThird = 0,
            skinFirst = tonumber(esxSkin.mom) or 0,
            skinSecond = tonumber(esxSkin.dad) or 0,
            skinThird = 0,
            shapeMix = tonumber(esxSkin.face_md_weight) or 0.5,
            skinMix = tonumber(esxSkin.skin_md_weight) or 0.5,
            thirdMix = 0.0
        }
    end
    
    if esxSkin.nose_1 ~= nil then
        unified.faceFeatures = {}
        for featureId, key in ipairs(faceFeaturesMapping) do
            unified.faceFeatures[featureId - 1] = tonumber(esxSkin[key]) or 0.0
        end
    end
    
    return unified
end

function Appearance.FromUnified(unified)
    if not unified then return nil end
    local esxSkin = {}
    
    if unified.model then
        local modelHash = type(unified.model) == "string" and joaat(unified.model) or unified.model
        if modelHash == 1885233650 then
            esxSkin.sex = 0
        else
            esxSkin.sex = 1
        end
    end
    
    if unified.hair then
        esxSkin.hair_1 = unified.hair.style or 0
        esxSkin.hair_2 = 0
        esxSkin.hair_color_1 = unified.hair.color or 0
        esxSkin.hair_color_2 = unified.hair.highlight or 0
    end
    
    esxSkin.eye_color = unified.eyeColor or 0
    
    if unified.components then
        for compId, keys in pairs(componentsMapping) do
            if unified.components[compId] then
                esxSkin[keys.drawable] = unified.components[compId].drawable or 0
                if keys.texture then
                    esxSkin[keys.texture] = unified.components[compId].texture or 0
                end
            end
        end
    end
    
    if unified.props then
        for propId, keys in pairs(propsMapping) do
            if unified.props[propId] then
                esxSkin[keys.drawable] = unified.props[propId].drawable or -1
                esxSkin[keys.texture] = unified.props[propId].texture or 0
            end
        end
    end
    
    if unified.headOverlays then
        for overlayId, keys in pairs(headOverlaysMapping) do
            if unified.headOverlays[overlayId] then
                esxSkin[keys.index] = unified.headOverlays[overlayId].index or 255
                esxSkin[keys.opacity] = unified.headOverlays[overlayId].opacity or 1.0
            end
        end
    end
    
    if unified.headBlend then
        esxSkin.mom = unified.headBlend.shapeFirst or 0
        esxSkin.dad = unified.headBlend.shapeSecond or 0
        esxSkin.face_md_weight = unified.headBlend.shapeMix or 0.5
        esxSkin.skin_md_weight = unified.headBlend.skinMix or 0.5
    end
    
    if unified.faceFeatures then
        for featureId, key in ipairs(faceFeaturesMapping) do
            esxSkin[key] = unified.faceFeatures[featureId - 1] or 0.0
        end
    end
    
    return esxSkin
end

if IsDuplicityVersion() then
    function Appearance.GetPlayerAppearance(playerId)
        local player = exports["CubX-Bridge"]:GetPlayer(playerId)
        if not player or not player.identifier then
            return nil
        end
        
        local skinData = exports.oxmysql:scalar_async("SELECT skin FROM users WHERE identifier = ?", {player.identifier})
        if not skinData then
            return nil
        end
        
        local success, decodedSkin = pcall(json.decode, skinData)
        if not success or not decodedSkin then
            return nil
        end
        
        return Appearance.ToUnified(decodedSkin)
    end
    
    function Appearance.SetPlayerAppearance(playerId, appearance)
        if not appearance then
            return false
        end
        local esxSkin = Appearance.FromUnified(appearance)
        TriggerClientEvent(Config.EventPrefix .. ":client:setAppearance", playerId, esxSkin)
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
        
        local esxSkin = Appearance.FromUnified(appearance)
        local encodedSkin = json.encode(esxSkin)
        
        exports.oxmysql:update_async("UPDATE users SET skin = ? WHERE identifier = ?", {encodedSkin, player.identifier})
        TriggerClientEvent(Config.EventPrefix .. ":client:setAppearance", playerId, esxSkin)
    end
else
    function Appearance.GetPedAppearance(ped)
        if not ped then
            ped = PlayerPedId()
        end
        
        local success, result = pcall(function()
            return exports.skinchanger:GetSkin()
        end)
        
        if success and result then
            return Appearance.ToUnified(result)
        end
        
        return Appearance.GetPedAppearanceNative(ped)
    end
    
    function Appearance.SetPedAppearance(ped, appearance)
        if not appearance then
            return
        end
        
        local esxSkin = Appearance.FromUnified(appearance)
        pcall(function()
            exports.skinchanger:LoadSkin(esxSkin)
        end)
    end
    
    function Appearance.SetAppearanceFromServer(appearance)
        if not appearance then
            return
        end
        
        local esxSkin = appearance
        if appearance.components then
            esxSkin = Appearance.FromUnified(appearance) or appearance
        end
        
        pcall(function()
            exports.skinchanger:LoadSkin(esxSkin)
        end)
    end
    
    function Appearance.SaveAppearance(appearance)
        local esxSkin = nil
        
        if appearance and appearance.components then
            esxSkin = Appearance.FromUnified(appearance)
        elseif appearance then
            esxSkin = appearance
        else
            local success, result = pcall(function()
                return exports.skinchanger:GetSkin()
            end)
            if not success or not result then
                return
            end
            esxSkin = result
        end
        
        TriggerServerEvent("esx_skin:save", esxSkin)
    end
    
    function Appearance.SetPedComponent(ped, componentId, drawableId, textureId)
        if not ped then
            ped = PlayerPedId()
        end
        SetPedComponentVariation(ped, componentId, drawableId, textureId, 0)
    end
    
    function Appearance.SetPedProp(ped, propId, drawableId, textureId)
        if not ped then
            ped = PlayerPedId()
        end
        if drawableId == -1 then
            ClearPedProp(ped, propId)
        else
            SetPedPropIndex(ped, propId, drawableId, textureId, true)
        end
    end
    
    function Appearance.SetPedHair(ped, hairId, color1, color2)
        if not ped then
            ped = PlayerPedId()
        end
        SetPedComponentVariation(ped, 2, hairId, 0, 0)
        SetPedHairColor(ped, color1 or 0, color2 or 0)
    end
    
    function Appearance.SetPedHeadOverlay(ped, overlayId, index, opacity, color1, color2)
        if not ped then
            ped = PlayerPedId()
        end
        SetPedHeadOverlay(ped, overlayId, index, opacity or 1.0)
        if color1 and color2 then
            SetPedHeadOverlayColor(ped, overlayId, color1, color2, color2 or color1)
        end
    end
    
    function Appearance.SetPedEyeColor(ped, index)
        if not ped then
            ped = PlayerPedId()
        end
        SetPedEyeColor(ped, index)
    end
    
    function Appearance.GetPedModel(ped)
        if not ped then
            ped = PlayerPedId()
        end
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

CBUX.RegisterModule("appearances", "esx_skin", Appearance)