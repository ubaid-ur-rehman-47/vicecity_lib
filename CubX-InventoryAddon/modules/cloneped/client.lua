--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

CubXPedPreview = {}
local clonedPed = nil
local isActive = false
local isCreating = false

function CubXPedPreview.IsCreating()
    return isCreating
end

function CubXPedPreview.Create()
    if isActive then return end
    isActive = true
    isCreating = true
    
    CreateThread(function()
        local playerPed = PlayerPedId()
        SetFrontendActive(true)
        ActivateFrontendMenu(-2060115030, true, -1)
        
        local attempts = 0
        while not IsFrontendReadyForControl() and attempts < 50 do
            Wait(10)
            attempts = attempts + 1
        end
        
        Wait(50)
        
        clonedPed = ClonePed(playerPed, false, false, false)
        SetEntityVisible(clonedPed, false, false)
        SetEntityCollision(clonedPed, false, true)
        SetPedAsNoLongerNeeded(clonedPed)
        GivePedToPauseMenu(clonedPed, 6)
        SetPauseMenuPedLighting(true)
        SetPauseMenuPedSleepState(true)
        
        ReplaceHudColourWithRgba(117, 0, 0, 0, 0)
        SetMouseCursorVisibleInMenus(false)
        
        exports.ox_inventory:setNuiFocus(true, true)
        exports.ox_inventory:setNuiFocusKeepInput(true)
        
        isCreating = false
    end)
    
    CreateThread(function()
        while isActive do
            SetMouseCursorVisibleInMenus(false)
            Wait(0)
        end
    end)
end

function CubXPedPreview.Destroy()
    if not isActive then return end
    isActive = false
    
    if clonedPed then
        if DoesEntityExist(clonedPed) then
            DeleteEntity(clonedPed)
            clonedPed = nil
        end
    end
    
    SetFrontendActive(false)
    ReplaceHudColourWithRgba(117, 0, 0, 0, 186)
end

function CubXPedPreview.IsActive()
    return isActive
end

function CubXPedPreview.Refresh()
    if not isActive then return end
    
    if clonedPed then
        if DoesEntityExist(clonedPed) then
            DeleteEntity(clonedPed)
        end
    end
    
    local playerPed = PlayerPedId()
    clonedPed = ClonePed(playerPed, false, false, false)
    SetEntityVisible(clonedPed, false, false)
    SetEntityCollision(clonedPed, false, true)
    SetPedAsNoLongerNeeded(clonedPed)
    GivePedToPauseMenu(clonedPed, 1)
    SetPauseMenuPedLighting(true)
    SetPauseMenuPedSleepState(true)
end

exports("createPedPreview", function()
    CubXPedPreview.Create()
end)

exports("destroyPedPreview", function()
    CubXPedPreview.Destroy()
end)

exports("isPedPreviewActive", function()
    return CubXPedPreview.IsActive()
end)

exports("isPedPreviewCreating", function()
    return CubXPedPreview.IsCreating()
end)

exports("refreshPedPreview", function()
    CubXPedPreview.Refresh()
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= "ox_inventory" then
        if resourceName ~= GetCurrentResourceName() then
            return
        end
    end
    
    if clonedPed then
        if DoesEntityExist(clonedPed) then
            DeleteEntity(clonedPed)
            clonedPed = nil
        end
    end
    
    isActive = false
    isCreating = false
    SetFrontendActive(false)
    ReplaceHudColourWithRgba(117, 0, 0, 0, 186)
end)