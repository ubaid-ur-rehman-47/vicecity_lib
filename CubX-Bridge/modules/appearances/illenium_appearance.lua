--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local Appearance = {}

function Appearance.Initialize()
    if GetResourceState("illenium-appearance") ~= "started" then
        CBUX.Utils.Error("illenium-appearance not started!")
        return false
    end
    CBUX.Utils.Debug("illenium-appearance module initialized")
    return true
end

if IsDuplicityVersion() then
    function Appearance.GetPlayerAppearance(playerId)
        local player = exports["CubX-Bridge"]:GetPlayer(playerId)
        if not player or not player.identifier then
            return nil
        end
        
        local skinData = nil
        if CBUX.Framework == "esx" then
            skinData = exports.oxmysql:scalar_async("SELECT skin FROM users WHERE identifier = ?", {player.identifier})
        else
            skinData = exports.oxmysql:scalar_async("SELECT skin FROM playerskins WHERE citizenid = ? AND active = 1 LIMIT 1", {player.identifier})
        end
        
        if not skinData then
            return nil
        end
        
        local success, decodedSkin = pcall(json.decode, skinData)
        if not success or not decodedSkin then
            return nil
        end
        
        if CBUX.Framework == "esx" then
            if decodedSkin.model then
                if decodedSkin.model == "mp_m_freemode_01" then
                    decodedSkin.sex = 0
                else
                    decodedSkin.sex = 1
                end
            end
        end
        
        return decodedSkin
    end
    
    function Appearance.SetPlayerAppearance(playerId, appearance)
        if not appearance then
            return false
        end
        TriggerClientEvent(Config.EventPrefix .. ":client:setAppearance", playerId, appearance)
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
        
        local identifier = player.identifier
        local encodedSkin = json.encode(appearance)
        
        if CBUX.Framework == "esx" then
            exports.oxmysql:update_async("UPDATE users SET skin = ? WHERE identifier = ?", {encodedSkin, identifier})
        else
            exports.oxmysql:update_async("UPDATE playerskins SET active = 0 WHERE citizenid = ?", {identifier})
            exports.oxmysql:execute_async("DELETE FROM playerskins WHERE citizenid = ? AND model = ?", {identifier, appearance.model})
            exports.oxmysql:insert_async("INSERT INTO playerskins (citizenid, model, skin, active) VALUES (?, ?, ?, 1)", {identifier, appearance.model, encodedSkin})
        end
        
        TriggerClientEvent("illenium-appearance:client:reloadSkin", playerId, true)
    end
else
    local function GetIlleniumExports()
        return exports["illenium-appearance"]
    end
    
    function Appearance.GetPedAppearance(ped)
        if not ped then
            ped = PlayerPedId()
        end
        local success, result = pcall(function()
            return GetIlleniumExports():getPedAppearance(ped)
        end)
        if success and result then
            return result
        end
        return nil
    end
    
    function Appearance.SetPedAppearance(ped, appearance)
        if not appearance then return end
        if not ped then
            ped = PlayerPedId()
        end
        pcall(function()
            GetIlleniumExports():setPedAppearance(ped, appearance)
        end)
    end
    
    function Appearance.SetAppearanceFromServer(appearance)
        if not appearance then return end
        pcall(function()
            GetIlleniumExports():setPlayerAppearance(appearance)
        end)
    end
    
    function Appearance.SaveAppearance(appearance)
        if not appearance then
            appearance = Appearance.GetPedAppearance(PlayerPedId())
        end
        if not appearance then return end
        TriggerServerEvent("illenium-appearance:server:saveAppearance", appearance)
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
            SetPedHeadOverlayColor(ped, overlayId, color1, color2, color2)
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
end

CBUX.RegisterModule("appearances", "illenium-appearance", Appearance)