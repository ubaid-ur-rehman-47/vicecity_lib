--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

CreateThread(function()
    local ready = CBUX.WaitForReady()
    if not ready then
        CBUX.Utils.Error("Failed to initialize client components - bridge not ready")
        return
    end
    
    CBUX.Utils.Debug("Client components initialized")
    
    while true do
        if exports["CubX-Bridge"]:IsPlayerLoaded() then
            break
        end
        Wait(500)
    end
    
    CBUX.Utils.Debug("Player loaded, client fully ready")
end)

RegisterNetEvent(Config.EventPrefix .. ":notify", function(message, type, length)
    exports["CubX-Bridge"]:Notify(message, type, length)
end)

RegisterNetEvent(Config.EventPrefix .. ":client:setComponent", function(componentId, drawableId, textureId)
    exports["CubX-Bridge"]:SetPedComponent(nil, componentId, drawableId, textureId)
end)

RegisterNetEvent(Config.EventPrefix .. ":client:setProp", function(componentId, drawableId, textureId)
    exports["CubX-Bridge"]:SetPedProp(nil, componentId, drawableId, textureId)
end)

RegisterNetEvent(Config.EventPrefix .. ":client:setHair", function(drawableId, textureId, highlightColor)
    exports["CubX-Bridge"]:SetPedHair(nil, drawableId, textureId, highlightColor)
end)

AddEventHandler("onResourceStart", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CBUX.Utils.Debug("CBUX Bridge client started")
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CBUX.Utils.Debug("CBUX Bridge client stopping")
        CBUX.PlayerData = nil
    end
end)