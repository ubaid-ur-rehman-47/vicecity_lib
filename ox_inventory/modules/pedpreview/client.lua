--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

PedPreview = {}
local clonedPed = nil
local isActive = false
local isCreating = false

function PedPreview.IsCreating()
    return isCreating
end

function PedPreview.Create()
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

        SetNuiFocus(true, true)
        SetNuiFocusKeepInput(true)

        isCreating = false
    end)

    CreateThread(function()
        while isActive do
            SetMouseCursorVisibleInMenus(false)
            Wait(0)
        end
    end)
end

function PedPreview.Destroy()
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

function PedPreview.IsActive()
    return isActive
end

function PedPreview.Refresh()
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
