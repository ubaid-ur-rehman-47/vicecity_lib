--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

CubXWeaponBack = {}
local Config = CubXWeaponBackConfig or {}
Config.maxSlots = 3
Config.bone = 24818
Config.detachOnEquip = true

Config.slots = {
    { pos = vec3(0.1, -0.16, -0.1), rot = vec3(180.0, 90.0, 0.0) },
    { pos = vec3(-0.1, -0.16, -0.1), rot = vec3(180.0, 90.0, 0.0) },
    { pos = vec3(0.0, -0.2, 0.12), rot = vec3(180.0, 90.0, 25.0) }
}

Config.weapons = {
    default = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) }
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

if type(CubXWeaponBackConfig) ~= "table" then
    CubXWeaponBackConfig = {}
end

mergeTables(CubXWeaponBackConfig, Config)
Config = CubXWeaponBackConfig

local stateBagName = "cubxWeaponBack"
local heldWeaponState = "cubxHeldWeapon"

local function getModel(item, itemModel)
    if type(item) == "string" then
        if item:find("^WEAPON_") then
            local model = GetWeapontypeModel(joaat(item))
            if model and model ~= 0 then return model end
        end
    end
    if type(itemModel) == "string" then return joaat(itemModel) end
    if type(itemModel) == "number" then return itemModel end
    return joaat("prop_cs_cardbox_01")
end

local function getSlotConfig(slotIndex)
    local slot = Config.slots[slotIndex]
    if not slot then
        slot = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) }
    end
    return slot
end

local function getWeaponConfig(item, model)
    local weapons = Config.weapons or {}
    local weaponConfig = nil
    
    if type(item) == "string" then
        local upperItem = string.upper(item)
        weaponConfig = weapons[upperItem] or weapons[item]
    else
        weaponConfig = weapons[model]
    end
    
    if not weaponConfig then
        weaponConfig = weapons.default or { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) }
    end
    
    local pos = weaponConfig.pos or vec3(0.0, 0.0, 0.0)
    local rot = weaponConfig.rot or vec3(0.0, 0.0, 0.0)
    local bone = weaponConfig.bone or Config.bone
    
    return pos, rot, bone
end

local attachedEntities = {}

local function updateVisibility(entity, stateData)
    if not Config.detachOnEquip then
        SetEntityVisible(entity, true, false)
        return
    end
    
    local playerState = Player(stateData.owner).state
    local heldWeapon = playerState[heldWeaponState]
    local isHoldingThisWeapon = false
    
    if heldWeapon and heldWeapon ~= 0 and heldWeapon ~= false then
        if type(stateData.weapon) == "string" then
            if joaat(stateData.weapon) == heldWeapon or stateData.weapon == heldWeapon then
                isHoldingThisWeapon = true
            end
        end
    end
    
    SetEntityVisible(entity, not isHoldingThisWeapon, false)
end

local function requestNetworkControl(entity)
    if NetworkHasControlOfEntity(entity) then return true end
    
    NetworkRequestControlOfEntity(entity)
    local attempts = 0
    while not NetworkHasControlOfEntity(entity) and attempts < 50 do
        Wait(10)
        NetworkRequestControlOfEntity(entity)
        attempts = attempts + 1
    end
    
    return NetworkHasControlOfEntity(entity)
end

local function handleEntityAttached(entity, stateData)
    if not stateData then
        if DoesEntityExist(entity) then
        end
        return
    end
    
    local playerId = GetPlayerFromServerId(stateData.owner)
    if playerId == -1 then return end
    
    local playerPed = GetPlayerPed(playerId)
    if not playerPed or playerPed == 0 then return end
    
    if not DoesEntityExist(playerPed) then return end
    
    if attachedEntities[entity] then
        if IsEntityAttachedToEntity(entity, playerPed) then
            updateVisibility(entity, stateData)
            return
        end
    end
    
    local slotConfig = getSlotConfig(stateData.back or 1)
    local wepPos, wepRot, wepBone = getWeaponConfig(stateData.weapon, stateData.model)
    
    local attachPos = vec3(slotConfig.pos.x + wepPos.x, slotConfig.pos.y + wepPos.y, slotConfig.pos.z + wepPos.z)
    local attachRot = vec3(slotConfig.rot.x + wepRot.x, slotConfig.rot.y + wepRot.y, slotConfig.rot.z + wepRot.z)
    
    local boneIndex = GetPedBoneIndex(playerPed, wepBone)
    if boneIndex == -1 then return end
    
    if not requestNetworkControl(entity) then return end
    
    SetEntityAsMissionEntity(entity, true, true)
    
    if IsEntityAttachedToEntity(entity, playerPed) then
        DetachEntity(entity, true, true)
    end
    
    AttachEntityToEntity(entity, playerPed, boneIndex, attachPos.x, attachPos.y, attachPos.z, attachRot.x, attachRot.y, attachRot.z, false, false, false, false, 2, true)
    
    attachedEntities[entity] = stateData
    updateVisibility(entity, stateData)
end

AddStateBagChangeHandler(stateBagName, nil, function(bagName, key, value)
    if value then
        CreateThread(function()
            local entity = 0
            local attempts = 0
            
            while entity == 0 and attempts < 100 do
                entity = GetEntityFromStateBagName(bagName)
                if entity == 0 then
                    Wait(50)
                end
                attempts = attempts + 1
            end
            
            if entity ~= 0 then
                handleEntityAttached(entity, value)
            end
        end)
    else
        local entity = GetEntityFromStateBagName(bagName)
        if entity ~= 0 then
            attachedEntities[entity] = nil
        end
    end
end)

CreateThread(function()
    for _, entity in ipairs(GetGamePool("CObject")) do
        local state = Entity(entity).state
        local stateData = state and state[stateBagName]
        if stateData then
            handleEntityAttached(entity, stateData)
        end
    end
end)

if Config.detachOnEquip then
    lib.onCache("weapon", function(value)
        LocalPlayer.state:set(heldWeaponState, value or 0, true)
    end)
end

AddStateBagChangeHandler(heldWeaponState, nil, function(bagName, key, value)
    if not Config.detachOnEquip then return end
    
    if not next(attachedEntities) then return end
    
    local serverId = tonumber(bagName:match("player:(%d+)"))
    if not serverId then return end
    
    for entity, stateData in pairs(attachedEntities) do
        if stateData.owner == serverId then
            if DoesEntityExist(entity) then
                updateVisibility(entity, stateData)
            else
                attachedEntities[entity] = nil
            end
        end
    end
end)

function CubXWeaponBack.Toggle(item, model)
    if type(item) ~= "table" or not item.slot then return end
    
    local resolvedModel = getModel(item.name, model)
    if not IsModelValid(resolvedModel) then
        print(string.format("^1[weaponback] Invalid model for %s^7", tostring(item.name)))
        return
    end
    
    lib.callback("cubx_weaponback:toggle", false, function(response)
        if type(response) ~= "table" then
            print("^1[weaponback] Invalid server response^7")
            return
        end
        
        if response.action == "attached" then
            print(string.format("^2[weaponback] %s attached on back (back slot %d)^7", tostring(item.name), response.back or -1))
        elseif response.action == "detached" then
            print(string.format("^3[weaponback] %s removed from back^7", tostring(item.name)))
        elseif response.action == "full" then
            print("^1[weaponback] No free back slot available^7")
        else
            print(string.format("^1[weaponback] Failure (%s)^7", tostring(response.action)))
        end
    end, item.slot, item.name, resolvedModel)
end

exports("toggleWeaponBack", function(...)
    return CubXWeaponBack.Toggle(...)
end)