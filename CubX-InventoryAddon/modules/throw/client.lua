--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

CubXThrow = {}
local Config = CubXThrowConfig or {}

Config.handBone = 57005
Config.force = 15.0
Config.gravity = 9.81

Config.trajectory = {
    enabled = true,
    points = 20,
    step = 0.08,
    color = {32, 201, 151},
    alpha = 255,
    landingMarker = {
        enabled = true,
        type = 28,
        scale = 0.1,
        color = {32, 201, 151},
        alpha = 180
    }
}

Config.offsets = {
    aim = vec3(0.0, 0.8, 0.5),
    throw = vec3(0.0, 1.0, 0.5)
}

Config.attachOffsets = {
    default = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },
    models = {}
}

Config.physics = {
    alignRotation = true,
    inheritPedVelocity = true,
    spinForce = 1.5,
    activatePhysics = true
}

Config.cancelControl = 73

Config.landing = {
    timeout = 200,
    velocityThreshold = 0.3,
    detectPlayerHit = true
}

Config.hit = {
    ragdollDuration = 3000,
    velocityDivisor = 6.0
}

Config.pickup = {
    enabled = true,
    dict = "pickup_object",
    clip = "pickup_low",
    flag = 48,
    duration = 900,
    serverCallDelay = 500
}

Config.dropInteraction = {
    type = "text3d",
    label = "Pick up item",
    icon = "fas fa-hand",
    target = {
        distance = 2.0,
        radius = 0.4
    },
    text3d = {
        message = "[E] Pick up",
        scale = 0.35,
        font = 4,
        color = {255, 255, 255},
        alpha = 255,
        maxDistance = 3.0,
        zOffset = 0.3,
        key = 38
    },
    textui = {
        message = "[E] Pick up",
        position = "right-center",
        icon = "fa-solid fa-hand",
        maxDistance = 1.5,
        key = 38
    }
}

local function mergeTables(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k]) == "table" then
                mergeTables(t1[k], v)
            else
                t1[k] = v
            end
        else
            if t1[k] == nil then
                t1[k] = v
            end
        end
    end
end

if type(CubXThrowConfig) ~= "table" then
    CubXThrowConfig = {}
end

mergeTables(CubXThrowConfig, Config)
Config = CubXThrowConfig

local defaultDropModel = joaat(GetConvar("inventory:dropmodel", "prop_med_bag_01b"))
local isThrowActive = false
local throwProp = nil
local activeDrops = {}
local isPickingUp = false

local function setThrowState(state)
    isThrowActive = state
    LocalPlayer.state:set("cubxThrowActive", state or nil, false)
end

local function cleanupThrowProp(ped)
    setThrowState(false)
    if DoesEntityExist(throwProp) then
        DeleteEntity(throwProp)
        throwProp = nil
    end
    SetPedInfiniteAmmoClip(ped, false)
    RemoveWeaponFromPed(ped, 126349499)
end

local function calculateTrajectory(startPos, camRot)
    local dir = vec3(
        -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
        math.sin(math.rad(camRot.x))
    )
    
    local velX = dir.x * Config.force
    local velY = dir.y * Config.force
    local velZ = dir.z * Config.force
    
    local points = {}
    for i = 1, Config.trajectory.points do
        local t = i * Config.trajectory.step
        local x = startPos.x + (velX * t)
        local y = startPos.y + (velY * t)
        local z = startPos.z + (velZ * t) - (0.5 * Config.gravity * t * t)
        points[i] = vec3(x, y, z)
    end
    
    return points
end

local function drawTrajectory(points)
    local r = Config.trajectory.color[1]
    local g = Config.trajectory.color[2]
    local b = Config.trajectory.color[3]
    local a = Config.trajectory.alpha or 255
    
    local numPoints = #points
    for i = 1, numPoints - 1 do
        local p1 = points[i]
        local p2 = points[i+1]
        
        local currentAlpha = math.floor((1.0 - (i / numPoints)) * a)
        DrawLine(p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, r, g, b, currentAlpha)
    end
    
    local marker = Config.trajectory.landingMarker
    local endPoint = points[numPoints]
    if marker.enabled and endPoint then
        DrawMarker(
            marker.type,
            endPoint.x, endPoint.y, endPoint.z,
            0.0, 0.0, 0.0,
            0.0, 0.0, 0.0,
            marker.scale, marker.scale, marker.scale,
            marker.color[1], marker.color[2], marker.color[3], marker.alpha,
            false, true, 2, false, nil, nil, false
        )
    end
end

local function getModel(item)
    if type(item) == "string" then
        if item:find("^WEAPON_") then
            local model = GetWeapontypeModel(joaat(item))
            return model
        end
        return joaat(item)
    end
    return item
end

local function getAttachOffsets(item, model)
    local offsets = Config.attachOffsets
    local models = offsets and offsets.models or nil
    local offset = nil
    
    if models then
        if type(item) == "string" then
            offset = models[item]
        else
            offset = models[model]
        end
    end
    
    if not offset then
        if offsets and offsets.default then
            offset = offsets.default
        else
            offset = {
                pos = vec3(0.0, 0.0, 0.0),
                rot = vec3(0.0, 0.0, 0.0)
            }
        end
    end
    
    local pos = offset.pos or vec3(0.0, 0.0, 0.0)
    local rot = offset.rot or vec3(0.0, 0.0, 0.0)
    
    return pos, rot
end

function CubXThrow.Start(item, itemModel)
    print("Started")
    if isThrowActive then return end
    
    if item and item.name then
        local configItem = exports.ox_inventory:Items(item.name)
        if configItem and configItem.permanent then
            lib.notify({
                description = locale("permanent_cannot_throw", configItem.label or item.name),
                type = "error"
            })
            return
        end
    end
    
    setThrowState(true)
    
    local ped = cache.ped
    local model = getModel(itemModel)
    if not IsModelValid(model) then
        model = defaultDropModel
    end
    
    GiveWeaponToPed(ped, 126349499, 1, false, true)
    SetCurrentPedWeapon(ped, 126349499, true)
    SetPedCurrentWeaponVisible(ped, false, false, false, false)
    
    lib.requestModel(model)
    local boneIndex = GetPedBoneIndex(ped, Config.handBone)
    local attachPos, attachRot = getAttachOffsets(itemModel, model)
    
    throwProp = CreateObject(model, 0.0, 0.0, 0.0, true, true, true)
    AttachEntityToEntity(
        throwProp, ped, boneIndex,
        attachPos.x, attachPos.y, attachPos.z,
        attachRot.x, attachRot.y, attachRot.z,
        true, true, false, true, 1, true
    )
    SetModelAsNoLongerNeeded(model)
    
    local isAiming = true
    local aimOffset = Config.offsets.aim
    local throwOffset = Config.offsets.throw
    
    CreateThread(function()
        while isAiming do
            SetPedCurrentWeaponVisible(ped, false, false, false, false)
            local pedCoords = GetEntityCoords(ped)
            local projectile = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 100.0, -536771815, false, false, false)
            
            while DoesEntityExist(projectile) do
                SetEntityAlpha(projectile, 0, false)
                SetEntityVisible(projectile, false, false)
                SetEntityCollision(projectile, false, false)
                DeleteObject(projectile)
                DeleteEntity(projectile)
                projectile = GetClosestObjectOfType(pedCoords.x, pedCoords.y, pedCoords.z, 100.0, -536771815, false, false, false)
            end
            
            RemoveAllProjectilesOfType(126349499, false)
            
            if Config.trajectory.enabled and isThrowActive then
                if IsPlayerFreeAiming(PlayerId()) then
                    local startPos = GetOffsetFromEntityInWorldCoords(ped, aimOffset.x, aimOffset.y, aimOffset.z)
                    local camRot = GetGameplayCamRot(0)
                    local points = calculateTrajectory(startPos, camRot)
                    drawTrajectory(points)
                end
            end
            Wait(0)
        end
    end)
    
    CreateThread(function()
        for i = 1, 10 do
            Wait(50)
            if not isThrowActive then return end
            
            if not HasPedGotWeapon(ped, 126349499, false) then
                GiveWeaponToPed(ped, 126349499, 1, false, true)
            end
            SetCurrentPedWeapon(ped, 126349499, true)
            SetPedInfiniteAmmoClip(ped, true)
        end
        
        while isThrowActive do
            Wait(0)
            
            if not HasPedGotWeapon(ped, 126349499, false) then
                GiveWeaponToPed(ped, 126349499, 1, false, true)
                SetCurrentPedWeapon(ped, 126349499, true)
            end
            SetPedInfiniteAmmoClip(ped, true)
            
            if IsControlJustPressed(0, Config.cancelControl) then
                CubXThrow.Cancel()
                lib.notify({
                    description = "Throw cancelled",
                    type = "inform"
                })
                break
            end
            
            if IsPedShooting(ped) then
                local camRot = GetGameplayCamRot(0)
                local dir = vec3(
                    -math.sin(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                    math.cos(math.rad(camRot.z)) * math.abs(math.cos(math.rad(camRot.x))),
                    math.sin(math.rad(camRot.x))
                )
                
                local throwPos = GetOffsetFromEntityInWorldCoords(ped, throwOffset.x, throwOffset.y, throwOffset.z)
                
                if DoesEntityExist(throwProp) then
                    DeleteEntity(throwProp)
                    throwProp = nil
                end
                
                lib.requestModel(model)
                local newProp = CreateObject(model, throwPos.x, throwPos.y, throwPos.z, true, true, true)
                SetEntityCollision(newProp, true, true)
                
                if Config.physics.activatePhysics then
                    ActivatePhysics(newProp)
                end
                
                if Config.physics.alignRotation then
                    SetEntityRotation(newProp, camRot.x, 0.0, camRot.z, 2, true)
                end
                
                local finalVel = vec3(dir.x * Config.force, dir.y * Config.force, dir.z * Config.force)
                if Config.physics.inheritPedVelocity then
                    local pedVel = GetEntityVelocity(ped)
                    finalVel = vec3(finalVel.x + pedVel.x, finalVel.y + pedVel.y, finalVel.z + pedVel.z)
                end
                
                SetEntityVelocity(newProp, finalVel.x, finalVel.y, finalVel.z)
                
                local spinForce = Config.physics.spinForce or 0.0
                if spinForce > 0 then
                    ApplyForceToEntity(newProp, 1, (math.random() - 0.5) * spinForce, (math.random() - 0.5) * spinForce, (math.random() - 0.5) * spinForce, 0.0, 0.12, 0.05, 0, false, true, true, false, true)
                end
                
                SetModelAsNoLongerNeeded(model)
                
                CreateThread(function()
                    local timeout = Config.landing.timeout
                    local hitDetected = false
                    local detectHit = Config.landing.detectPlayerHit
                    
                    while timeout > 0 do
                        if not DoesEntityExist(newProp) then break end
                        
                        if HasEntityCollidedWithAnything(newProp) then
                            if detectHit then
                                local propVel = GetEntityVelocity(newProp)
                                for _, playerId in ipairs(GetActivePlayers()) do
                                    local playerPed = GetPlayerPed(playerId)
                                    if playerPed ~= ped then
                                        if IsEntityTouchingEntity(newProp, playerPed) then
                                            if not IsPedRagdoll(playerPed) then
                                                TriggerServerEvent("cubx_inventory:throwHit", GetPlayerServerId(playerId), propVel)
                                                break
                                            end
                                        end
                                    end
                                end
                            end
                            hitDetected = true
                            break
                        end
                        
                        local currentVel = GetEntityVelocity(newProp)
                        if #currentVel < Config.landing.velocityThreshold then
                            hitDetected = true
                            break
                        end
                        
                        timeout = timeout - 1
                        Wait(50)
                    end
                    
                    local finalCoords = nil
                    if DoesEntityExist(newProp) then
                        finalCoords = GetEntityCoords(newProp)
                        DeleteEntity(newProp)
                    else
                        finalCoords = GetEntityCoords(ped)
                    end
                    
                    TriggerServerEvent("cubx_inventory:throwItem", item.slot, finalCoords, model)
                end)
                
                cleanupThrowProp(ped)
                Wait(500)
                isAiming = false
                break
            end
        end
    end)
end

function CubXThrow.IsActive()
    return isThrowActive
end

function CubXThrow.Cancel()
    if not isThrowActive then return end
    cleanupThrowProp(cache.ped)
    ClearPedTasks(cache.ped)
end

local function handlePickup(dropId)
    if isPickingUp then return end
    isPickingUp = true
    
    CubXThrow.Cancel()
    
    local delay = 0
    if Config.pickup.enabled then
        delay = Config.pickup.serverCallDelay or 0
    end
    
    SetTimeout(delay, function()
        lib.callback("cubx_inventory:pickupThrownDrop", false, function(success)
            isPickingUp = false
            ClearPedTasks(cache.ped)
            if not success then
                lib.notify({
                    description = "Cannot pick up this item",
                    type = "error"
                })
            end
        end, dropId)
    end)
end

local function addTargetZone(dropId, coords)
    if GetResourceState("ox_target") ~= "started" then return end
    
    local dropTarget = Config.dropInteraction
    local zoneId = exports.ox_target:addSphereZone({
        coords = coords,
        radius = dropTarget.target.radius,
        debug = false,
        options = {
            {
                name = string.format("cubx_inventory:throwPickup_%s", dropId),
                icon = dropTarget.icon,
                label = dropTarget.label,
                distance = dropTarget.target.distance,
                onSelect = function()
                    handlePickup(dropId)
                end
            }
        }
    })
    
    activeDrops[dropId] = {
        coords = coords,
        zoneId = zoneId,
        mode = "target"
    }
end

local function addTextZone(dropId, coords, mode)
    activeDrops[dropId] = {
        coords = coords,
        mode = mode
    }
end

local function setupDropInteraction(dropId, dropData)
    if activeDrops[dropId] then return end
    
    local intType = Config.dropInteraction.type
    if intType == "none" then return end
    
    if intType == "target" then
        return addTargetZone(dropId, dropData)
    elseif intType == "text3d" or intType == "textui" then
        return addTextZone(dropId, dropData, intType)
    end
end

local function removeDropInteraction(dropId)
    local dropInfo = activeDrops[dropId]
    if not dropInfo then return end
    
    if dropInfo.zoneId then
        if GetResourceState("ox_target") == "started" then
            exports.ox_target:removeZone(dropInfo.zoneId)
        end
    end
    
    activeDrops[dropId] = nil
end

RegisterNetEvent("cubx_inventory:throwHit", function(velocity)
    if not velocity then return end
    
    local hitConfig = Config.hit
    SetPedToRagdoll(cache.ped, hitConfig.ragdollDuration, hitConfig.ragdollDuration, 0, 0, 0, 0)
    
    if type(velocity) == "vector3" then
        local divisor = hitConfig.velocityDivisor
        SetEntityVelocity(cache.ped, velocity.x / divisor, velocity.y / divisor, velocity.z / divisor)
    end
end)

RegisterNetEvent("ox_inventory:createDrop", function(dropId, dropData)
    if not dropData or not dropData.thrown then return end
    if not dropData.coords then return end
    
    setupDropInteraction(dropId, dropData.coords)
end)

RegisterNetEvent("ox_inventory:removeDrop", function(dropId)
    removeDropInteraction(dropId)
end)

RegisterNetEvent("ox_inventory:setPlayerInventory", function(inventory)
    if type(inventory) ~= "table" then return end
    
    for dropId, dropData in pairs(inventory) do
        if dropData.thrown and dropData.coords then
            setupDropInteraction(dropId, dropData.coords)
        end
    end
end)

local function drawText3D(coords, text, config)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextFont(config.font)
    SetTextProportional(1)
    SetTextScale(0.0, config.scale)
    SetTextColour(config.color[1], config.color[2], config.color[3], config.alpha)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

local maxDrawDistance = 5.0

CreateThread(function()
    local currentTextUI = nil
    
    while true do
        local intType = Config.dropInteraction.type
        if intType == "text3d" or intType == "textui" then
            if not next(activeDrops) then
                if currentTextUI then
                    lib.hideTextUI()
                    currentTextUI = nil
                end
                Wait(1000)
            else
                local pedCoords = GetEntityCoords(cache.ped)
                local closestDropId = nil
                local closestDist = nil
                
                for dropId, dropInfo in pairs(activeDrops) do
                    local dist = #(pedCoords - dropInfo.coords)
                    if not closestDist or closestDist > dist then
                        closestDist = dist
                        closestDropId = dropId
                    end
                end
                
                if closestDist and closestDist > maxDrawDistance then
                    if currentTextUI then
                        lib.hideTextUI()
                        currentTextUI = nil
                    end
                    Wait(1000)
                else
                    if intType == "text3d" then
                        local text3dConfig = Config.dropInteraction.text3d
                        local foundClose = false
                        
                        for dropId, dropInfo in pairs(activeDrops) do
                            local dist = #(pedCoords - dropInfo.coords)
                            if dist <= text3dConfig.maxDistance then
                                local drawCoords = vec3(dropInfo.coords.x, dropInfo.coords.y, dropInfo.coords.z + text3dConfig.zOffset)
                                drawText3D(drawCoords, text3dConfig.message, text3dConfig)
                                
                                if not closestDist or closestDist > dist then
                                    closestDist = dist
                                    closestDropId = dropId
                                end
                                foundClose = true
                            end
                        end
                        
                        if closestDropId then
                            if IsControlJustReleased(0, text3dConfig.key) then
                                handlePickup(closestDropId)
                            end
                        end
                    else
                        local textuiConfig = Config.dropInteraction.textui
                        local validDist = closestDist and closestDist <= textuiConfig.maxDistance
                        local activeDrop = validDist and closestDropId or nil
                        
                        if activeDrop then
                            if currentTextUI ~= activeDrop then
                                currentTextUI = activeDrop
                                lib.showTextUI(textuiConfig.message, {
                                    position = textuiConfig.position,
                                    icon = textuiConfig.icon
                                })
                            end
                            
                            if IsControlJustReleased(0, textuiConfig.key) then
                                handlePickup(activeDrop)
                            end
                        elseif currentTextUI then
                            lib.hideTextUI()
                            currentTextUI = nil
                        end
                    end
                    
                    Wait(0)
                end
            end
        else
            if currentTextUI then
                lib.hideTextUI()
                currentTextUI = nil
            end
            Wait(1000)
        end
    end
end)

exports("startThrow", function(...) return CubXThrow.Start(...) end)
exports("isThrowActive", function(...) return CubXThrow.IsActive(...) end)
exports("cancelThrow", function(...) return CubXThrow.Cancel(...) end)