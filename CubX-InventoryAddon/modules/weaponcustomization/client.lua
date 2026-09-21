--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

CubXWeaponCustomization = {}

local weaponObject = nil
local previewCam = nil
local isPreviewActive = false
local currentWeaponHash = nil
local currentItemSlot = nil
local camFov = 0.0
local camRotX = 0.0
local camRotZ = 0.0
local availableSlots = {}
local previewHoverState = nil
local previewDummyPed = nil

local componentOffsets = {
    muzzle = { bones = { "WAPSupp", "gun_muzzle" }, offset = vec3(0.0, 0.08, 0.15) },
    scope = { bones = { "WAPScope", "WAPScope2", "gun_body" }, offset = vec3(0.0, -0.03, 0.18) },
    sight = { bones = { "WAPScope", "WAPScope2", "gun_body" }, offset = vec3(0.0, -0.03, 0.18) },
    grip = { bones = { "WAPGrip" }, offset = vec3(0.0, 0.0, -0.16) },
    flashlight = { bones = { "WAPGrip", "gun_barrel" }, offset = vec3(0.0, 0.0, 0.15) },
    barrel = { bones = { "WAPBarrel", "gun_barrel" }, offset = vec3(0.0, 0.05, -0.14) },
    magazine = { bones = { "WAPClip", "WAPClip2", "gun_magazine" }, offset = vec3(0.0, 0.0, 0.18) },
    skin = { bones = { "gun_body", "gun_root" }, offset = vec3(0.0, 0.0, -0.18) }
}

local function getItems()
    return exports.ox_inventory:Items()
end

local function getPlayerItems()
    return exports.ox_inventory:GetPlayerItems()
end

local function spawnDummyPed()
    if previewDummyPed then
        if DoesEntityExist(previewDummyPed) then
            DeleteEntity(previewDummyPed)
            previewDummyPed = nil
        end
    end
    
    local coords = GetEntityCoords(cache.ped)
    local spawnCoords = coords + vector3(0.0, 0.0, -50.0)
    local pedModel = 1885233650
    
    lib.requestModel(pedModel)
    local ped = CreatePed(4, pedModel, spawnCoords.x, spawnCoords.y, spawnCoords.z, 0.0, false, false)
    previewDummyPed = ped
    SetModelAsNoLongerNeeded(pedModel)
    
    if previewDummyPed then
        if DoesEntityExist(previewDummyPed) then
            SetEntityVisible(previewDummyPed, false, false)
            SetEntityInvincible(previewDummyPed, true)
            FreezeEntityPosition(previewDummyPed, true)
            SetEntityCollision(previewDummyPed, false, false)
            SetEntityAlpha(previewDummyPed, 0, false)
            SetBlockingOfNonTemporaryEvents(previewDummyPed, true)
            Wait(50)
            return true
        end
    end
    
    previewDummyPed = nil
    return false
end

local function destroyDummyPed()
    if previewDummyPed then
        if DoesEntityExist(previewDummyPed) then
            DeleteEntity(previewDummyPed)
            previewDummyPed = nil
        end
    end
end

local function forceComponentAttach(weaponHash)
    if not spawnDummyPed() then return end
    
    GiveWeaponToPed(previewDummyPed, weaponHash, 999, false, true)
    SetCurrentPedWeapon(previewDummyPed, weaponHash, true)
    Wait(100)
    
    local playerItems = getPlayerItems()
    for _, item in pairs(playerItems) do
        if item.component and item.client and item.client.component then
            for _, compHash in ipairs(item.client.component) do
                if DoesWeaponTakeWeaponComponent(weaponHash, compHash) then
                    if not HasPedGotWeaponComponent(previewDummyPed, weaponHash, compHash) then
                        GiveWeaponComponentToPed(previewDummyPed, weaponHash, compHash)
                    end
                end
            end
        end
    end
    
    SetCurrentPedWeapon(previewDummyPed, weaponHash, true)
    Wait(200)
end

local function getOwnedComponents(weaponHash)
    local owned = {}
    local configItems = getItems()
    local playerItems = getPlayerItems()
    
    for slot, item in pairs(playerItems) do
        if item and item.name then
            local configItem = configItems[item.name]
            if configItem and configItem.component and configItem.client and configItem.client.component then
                for _, compHash in ipairs(configItem.client.component) do
                    if DoesWeaponTakeWeaponComponent(weaponHash, compHash) then
                        owned[#owned + 1] = {
                            name = item.name,
                            label = configItem.label or item.name,
                            slot = slot,
                            type = configItem.type or "",
                            owned = true
                        }
                        break
                    end
                end
            end
        end
    end
    
    return owned
end

local function getAllComponents(weaponHash)
    local all = {}
    local processedTypes = {}
    local configItems = getItems()
    
    for itemName, configItem in pairs(configItems) do
        if configItem.component and configItem.client and configItem.client.component then
            if not processedTypes[itemName] then
                for _, compHash in ipairs(configItem.client.component) do
                    if DoesWeaponTakeWeaponComponent(weaponHash, compHash) then
                        processedTypes[itemName] = true
                        all[#all + 1] = {
                            name = itemName,
                            label = configItem.label or itemName,
                            type = configItem.type or ""
                        }
                        break
                    end
                end
            end
        end
    end
    
    return all
end

local function openCustomization(data, cb)
    local playerItems = getPlayerItems()
    local weaponItem = playerItems[data.slot]
    if not weaponItem then return end
    
    local configItems = getItems()
    local configItem = configItems[weaponItem.name]
    
    local baseWeight = 0
    if configItem and configItem.weight then
        baseWeight = configItem.weight
    end
    
    local weaponWeight = weaponItem.weight or baseWeight
    
    exports.ox_inventory:sendNuiMessage({
        action = "openWeaponCustomization",
        data = {
            show = true,
            weaponName = weaponItem.name,
            weaponLabel = configItem and configItem.label or weaponItem.name,
            ownedComponents = getOwnedComponents(cb),
            allComponents = getAllComponents(cb),
            attachedComponents = weaponItem.metadata and weaponItem.metadata.components or {},
            weaponWeight = weaponWeight,
            baseWeight = baseWeight
        }
    })
end

local function getComponentSlotPositions()
    if not weaponObject then return {} end
    if not DoesEntityExist(weaponObject) then return {} end
    
    local positions = {}
    
    local itemConfig = nil
    if currentItemSlot then
        local playerItems = getPlayerItems()
        local weaponItem = playerItems[currentItemSlot]
        if weaponItem then
            local attachedComponents = weaponItem.metadata and weaponItem.metadata.components
            if attachedComponents then
                local itemsConfig = getItems()
                for _, compName in ipairs(attachedComponents) do
                    local compConfig = itemsConfig[compName]
                    if compConfig and compConfig.type then
                        positions[compConfig.type] = compName
                    end
                end
            end
        end
    end
    
    local objCoords = GetEntityCoords(weaponObject)
    local slotsFound = {}
    local resultSlots = {}
    
    for compType, compData in pairs(componentOffsets) do
        if not slotsFound[compType] then
            slotsFound[compType] = true
            local boneIndex = -1
            
            for _, boneName in ipairs(compData.bones) do
                boneIndex = GetEntityBoneIndexByName(weaponObject, boneName)
                if boneIndex ~= -1 then break end
            end
            
            local bonePos = objCoords
            if boneIndex ~= -1 then
                local worldPos = GetWorldPositionOfEntityBone(weaponObject, boneIndex)
                if worldPos then
                    bonePos = worldPos
                end
            end
            
            local offsetPos = GetOffsetFromEntityInWorldCoords(weaponObject, compData.offset.x, compData.offset.y, compData.offset.z)
            local finalPos = bonePos + (offsetPos - objCoords)
            
            local onScreen1, screenX1, screenY1 = GetScreenCoordFromWorldCoord(bonePos.x, bonePos.y, bonePos.z)
            local onScreen2, screenX2, screenY2 = GetScreenCoordFromWorldCoord(finalPos.x, finalPos.y, finalPos.z)
            
            if onScreen1 and onScreen2 then
                resultSlots[#resultSlots + 1] = {
                    type = compType,
                    boneX = screenX1,
                    boneY = screenY1,
                    slotX = screenX2,
                    slotY = screenY2,
                    attachedName = positions[compType] or false
                }
            end
        end
    end
    
    return resultSlots
end

local function cleanupPreview()
    if DoesEntityExist(weaponObject) then
        DeleteEntity(weaponObject)
    end
    
    if DoesCamExist(previewCam) then
        RenderScriptCams(false, true, 300, true, false)
        DestroyCam(previewCam, false)
    end
    
    if currentWeaponHash then
        if HasWeaponAssetLoaded(currentWeaponHash) then
            RemoveWeaponAsset(currentWeaponHash)
        end
    end
    
    destroyDummyPed()
    
    weaponObject = nil
    previewCam = nil
    isPreviewActive = false
    currentWeaponHash = nil
    currentItemSlot = nil
    availableSlots = {}
    previewHoverState = nil
    previewDummyPed = nil
    camFov = 0.0
    camRotX = 0.0
    camRotZ = 0.0
    
    exports.ox_inventory:setNuiFocus(false, false)
    exports.ox_inventory:sendNuiMessage({
        action = "closeWeaponCustomization"
    })
end

function CubXWeaponCustomization.HandlePreview(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    if isPreviewActive then
        return cleanupPreview()
    end
    
    local playerItems = getPlayerItems()
    local weaponItem = playerItems[data.slot]
    if not weaponItem then return end
    
    local configItems = getItems()
    local configItem = configItems[weaponItem.name]
    if not configItem or not configItem.weapon then return end
    
    local weaponHash = configItem.hash
    if not weaponHash then
        weaponHash = joaat(configItem.model or weaponItem.name)
    end
    
    if GetWeapontypeModel(weaponHash) == 0 then return end
    
    currentWeaponHash = weaponHash
    currentItemSlot = data.slot
    
    exports.ox_inventory:closeInventory()
    Wait(300)
    
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local radHeading = math.rad(heading)
    
    local targetCoords = vector3(
        coords.x - math.sin(radHeading) * 2.0,
        coords.y + math.cos(radHeading) * 2.0,
        coords.z + 0.3
    )
    
    camRotZ = heading - 180.0
    forceComponentAttach(weaponHash)
    
    RequestWeaponAsset(weaponHash, 31, 0)
    while not HasWeaponAssetLoaded(weaponHash) do
        Wait(10)
    end
    
    weaponObject = CreateWeaponObject(weaponHash, 1, targetCoords.x, targetCoords.y, targetCoords.z, true, 1.0, 0)
    SetEntityHeading(weaponObject, heading - 180.0)
    
    if not weaponObject or not DoesEntityExist(weaponObject) then
        weaponObject = nil
        return
    end
    
    FreezeEntityPosition(weaponObject, true)
    SetEntityCollision(weaponObject, false, false)
    SetEntityVisible(weaponObject, true, false)
    SetEntityAlpha(weaponObject, 255, false)
    
    local components = weaponItem.metadata and weaponItem.metadata.components or {}
    for i = 1, #components do
        local compItem = components[i]
        local compConfig = configItems[compItem]
        if compConfig and compConfig.client and compConfig.client.component then
            for _, compHash in ipairs(compConfig.client.component) do
                if DoesWeaponTakeWeaponComponent(weaponHash, compHash) then
                    pcall(GiveWeaponComponentToWeaponObject, weaponObject, compHash)
                    break
                end
            end
        end
    end
    
    if weaponItem.metadata and weaponItem.metadata.tint then
        pcall(SetWeaponObjectTintIndex, weaponObject, weaponItem.metadata.tint)
    end
    
    local objCoords = GetEntityCoords(weaponObject)
    
    previewCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local camCoords = vector3(
        objCoords.x + math.sin(radHeading) * 1.6,
        objCoords.y - math.cos(radHeading) * 1.6,
        objCoords.z + 0.05
    )
    
    SetCamCoord(previewCam, camCoords.x, camCoords.y, camCoords.z)
    PointCamAtCoord(previewCam, objCoords.x, objCoords.y, objCoords.z)
    SetCamActive(previewCam, true)
    RenderScriptCams(true, true, 500, true, false)
    
    SetCamFov(previewCam, 30.0)
    isPreviewActive = true
    
    local initialSlots = getComponentSlotPositions()
    availableSlots = {}
    
    for _, slot in ipairs(initialSlots) do
        if slot.type and slot.type ~= "" then
            availableSlots[slot.type] = true
        end
    end
    
    exports.ox_inventory:setNuiFocus(true, true)
    openCustomization(data, weaponHash)
    
    CreateThread(function()
        local tick = 0
        while isPreviewActive do
            DisableAllControlActions(0)
            HideHudAndRadarThisFrame()
            
            tick = tick + 1
            if tick % 5 == 0 then
                exports.ox_inventory:sendNuiMessage({
                    action = "updateSlotPositions",
                    data = getComponentSlotPositions()
                })
            end
            Wait(0)
        end
    end)
end

function CubXWeaponCustomization.HandleRotate(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    if not isPreviewActive or not DoesEntityExist(weaponObject) then return end
    
    local speed = 300.0
    if data.rightClick then
        camRotZ = camRotZ + (data.deltaX * speed)
    else
        camRotX = camRotX + (data.deltaX * speed)
    end
    
    camFov = camFov + (data.deltaY * speed)
    
    SetEntityRotation(weaponObject, camFov, camRotX, camRotZ, 2, true)
end

function CubXWeaponCustomization.HandleZoom(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    if not isPreviewActive or not DoesCamExist(previewCam) then return end
    
    local fov = math.max(10.0, math.min(60.0, GetCamFov(previewCam) - (data.delta * 2.0)))
    SetCamFov(previewCam, fov)
end

local function refreshWeaponPreview(newComponents, tintIndex)
    if not weaponObject or not DoesEntityExist(weaponObject) then return end
    if not previewDummyPed or not DoesEntityExist(previewDummyPed) then return end
    
    local itemsConfig = getItems()
    
    RemoveAllPedWeapons(previewDummyPed, true)
    GiveWeaponToPed(previewDummyPed, currentWeaponHash, 999, false, true)
    SetCurrentPedWeapon(previewDummyPed, currentWeaponHash, true)
    Wait(50)
    
    if GetSelectedPedWeapon(previewDummyPed) ~= currentWeaponHash then
        SetCurrentPedWeapon(previewDummyPed, currentWeaponHash, true)
        Wait(50)
    end
    
    for i = 1, #newComponents do
        local compName = newComponents[i]
        local compConfig = itemsConfig[compName]
        if compConfig and compConfig.client and compConfig.client.component then
            for _, compHash in ipairs(compConfig.client.component) do
                if DoesWeaponTakeWeaponComponent(currentWeaponHash, compHash) then
                    if not HasPedGotWeaponComponent(previewDummyPed, currentWeaponHash, compHash) then
                        GiveWeaponComponentToPed(previewDummyPed, currentWeaponHash, compHash)
                    end
                end
            end
        end
    end
    
    SetCurrentPedWeapon(previewDummyPed, currentWeaponHash, true)
    Wait(200)
    
    local oldObj = weaponObject
    local objCoords = GetEntityCoords(oldObj)
    
    local success, newObj = pcall(CreateWeaponObject, currentWeaponHash, 1, objCoords.x, objCoords.y, objCoords.z, true, 1.0, 0)
    
    if not success or not newObj or not DoesEntityExist(newObj) then
        weaponObject = oldObj
        return
    end
    
    weaponObject = newObj
    SetEntityCoords(weaponObject, objCoords.x, objCoords.y, objCoords.z, false, false, false, true)
    SetEntityRotation(weaponObject, camFov, camRotX, camRotZ, 2, true)
    FreezeEntityPosition(weaponObject, true)
    SetEntityCollision(weaponObject, false, false)
    SetEntityVisible(weaponObject, true, false)
    SetEntityAlpha(weaponObject, 255, false)
    
    for i = 1, #newComponents do
        local compName = newComponents[i]
        local compConfig = itemsConfig[compName]
        if compConfig and compConfig.client and compConfig.client.component then
            for _, compHash in ipairs(compConfig.client.component) do
                if DoesWeaponTakeWeaponComponent(currentWeaponHash, compHash) then
                    pcall(GiveWeaponComponentToWeaponObject, weaponObject, compHash)
                    break
                end
            end
        end
    end
    
    if tintIndex then
        pcall(SetWeaponObjectTintIndex, weaponObject, tintIndex)
    end
    
    Wait(1)
    DeleteEntity(oldObj)
end

local function getUpdatedComponentsAndTint(addedComponent)
    local playerItems = getPlayerItems()
    local weaponItem = playerItems[currentItemSlot]
    if not weaponItem then return {} end
    
    local currentComponents = {}
    local weaponComponents = weaponItem.metadata and weaponItem.metadata.components or {}
    
    for i = 1, #weaponComponents do
        currentComponents[#currentComponents + 1] = weaponComponents[i]
    end
    
    if addedComponent then
        currentComponents[#currentComponents + 1] = addedComponent
    end
    
    return currentComponents, weaponItem.metadata and weaponItem.metadata.tint
end

function CubXWeaponCustomization.HandleComponent(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    if not isPreviewActive or not currentWeaponHash or not currentItemSlot then return end
    
    local configItems = getItems()
    local compConfig = configItems[data.name]
    if not compConfig or not compConfig.client or not compConfig.client.component then return end
    
    local playerItems = getPlayerItems()
    
    if data.action == "add" then
        local weaponItem = playerItems[currentItemSlot]
        local existingComponents = weaponItem and weaponItem.metadata and weaponItem.metadata.components or {}
        
        for i = 1, #existingComponents do
            local existingCompName = existingComponents[i]
            local existingCompConfig = configItems[existingCompName]
            if compConfig.type and existingCompConfig and compConfig.type == existingCompConfig.type then
                lib.notify({
                    id = "component_slot_occupied",
                    type = "error",
                    description = locale("component_slot_occupied", compConfig.type)
                })
                return
            end
        end
        
        local itemSlot = nil
        for slot, item in pairs(playerItems) do
            if item and item.name == data.name then
                itemSlot = slot
                break
            end
        end
        
        if not itemSlot then
            lib.notify({
                type = "error",
                description = locale("item_not_enough", compConfig.label or data.name)
            })
            return
        end
        
        for _, compHash in ipairs(compConfig.client.component) do
            if DoesWeaponTakeWeaponComponent(currentWeaponHash, compHash) then
                local success = lib.callback.await("ox_inventory:updateWeapon", false, "component", tostring(itemSlot), currentItemSlot)
                if success then
                    local weapon = playerItems[currentItemSlot]
                    if weapon then
                        weapon.metadata = weapon.metadata or {}
                        weapon.metadata.components = weapon.metadata.components or {}
                        table.insert(weapon.metadata.components, data.name)
                    end
                    
                    playerItems[itemSlot] = nil
                    
                    pcall(GiveWeaponComponentToWeaponObject, weaponObject, compHash)
                    TriggerEvent("ox_inventory:updateWeaponComponent", "added", compHash, data.name)
                    
                    openCustomization(data, currentWeaponHash)
                end
                break
            end
        end
        
    elseif data.action == "remove" then
        local weaponItem = playerItems[currentItemSlot]
        if not weaponItem then return end
        
        local newComponentsList = {}
        local tint = weaponItem.metadata and weaponItem.metadata.tint
        local existingComponents = weaponItem.metadata and weaponItem.metadata.components or {}
        
        for _, compName in ipairs(existingComponents) do
            if compName ~= data.name then
                newComponentsList[#newComponentsList + 1] = compName
            end
        end
        
        if weaponItem.metadata then
            weaponItem.metadata.components = newComponentsList
        end
        
        TriggerServerEvent("ox_inventory:updateWeapon", "component", { component = data.name, slot = currentItemSlot })
        
        refreshWeaponPreview(newComponentsList, tint)
        
        TriggerEvent("ox_inventory:updateWeaponComponent", "removed", 0, data.name)
        openCustomization(data, currentWeaponHash)
    end
end

function CubXWeaponCustomization.HandleHover(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    if not isPreviewActive or not DoesEntityExist(weaponObject) or not currentWeaponHash then return end
    
    local configItems = getItems()
    local compConfig = configItems[data.name]
    
    if not compConfig or not compConfig.client or not compConfig.client.component then return end
    
    local isSkin = compConfig.type == "skin"
    
    if previewHoverState then
        if not previewHoverState.isSkin then
            for _, compHash in ipairs(previewHoverState.hashes) do
                pcall(RemoveWeaponComponentFromWeaponObject, weaponObject, compHash)
            end
        end
        previewHoverState = nil
    end
    
    if isSkin then
        local comps, tint = getUpdatedComponentsAndTint(data.name)
        refreshWeaponPreview(comps, tint)
        previewHoverState = {
            isSkin = true,
            name = data.name,
            hashes = {}
        }
    else
        local addedHashes = {}
        for _, compHash in ipairs(compConfig.client.component) do
            if DoesWeaponTakeWeaponComponent(currentWeaponHash, compHash) then
                if pcall(GiveWeaponComponentToWeaponObject, weaponObject, compHash) then
                    addedHashes[#addedHashes + 1] = compHash
                end
            end
        end
        
        if #addedHashes > 0 then
            previewHoverState = {
                isSkin = false,
                name = data.name,
                hashes = addedHashes
            }
        end
    end
end

function CubXWeaponCustomization.HandleUnhover(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    if not isPreviewActive or not DoesEntityExist(weaponObject) then return end
    
    if not previewHoverState then return end
    
    if previewHoverState.isSkin then
        local comps, tint = getUpdatedComponentsAndTint()
        refreshWeaponPreview(comps, tint)
    else
        for _, compHash in ipairs(previewHoverState.hashes) do
            pcall(RemoveWeaponComponentFromWeaponObject, weaponObject, compHash)
        end
    end
    
    previewHoverState = nil
end

function CubXWeaponCustomization.HandleClose(data, cb)
    if cb then cb({ { name = "dummy" } }) end
    cleanupPreview()
end

function CubXWeaponCustomization.IsActive()
    return isPreviewActive
end

function CubXWeaponCustomization.Close()
    if isPreviewActive then
        cleanupPreview()
    end
end

exports("handleWeaponPreview", function(...) return CubXWeaponCustomization.HandlePreview(...) end)
exports("handleWeaponPreviewRotate", function(...) return CubXWeaponCustomization.HandleRotate(...) end)
exports("handleWeaponPreviewZoom", function(...) return CubXWeaponCustomization.HandleZoom(...) end)
exports("handleWeaponPreviewComponent", function(...) return CubXWeaponCustomization.HandleComponent(...) end)
exports("handleWeaponPreviewHover", function(...) return CubXWeaponCustomization.HandleHover(...) end)
exports("handleWeaponPreviewUnhover", function(...) return CubXWeaponCustomization.HandleUnhover(...) end)
exports("handleWeaponPreviewClose", function(...) return CubXWeaponCustomization.HandleClose(...) end)
exports("isWeaponCustomizationActive", function(...) return CubXWeaponCustomization.IsActive(...) end)
exports("closeWeaponCustomization", function(...) return CubXWeaponCustomization.Close(...) end)