--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not lib then return end

local Config = {
    maxSlots = 3
}

if CubXWeaponBackConfig then
    Config = CubXWeaponBackConfig
end

local playerBackWeapons = {}

lib.callback.register("cubx_weaponback:toggle", function(source, itemSlot, itemName, model)
    local src = source
    if not playerBackWeapons[src] then playerBackWeapons[src] = {} end
    
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    
    for i, data in pairs(playerBackWeapons[src]) do
        if data.itemSlot == itemSlot then
            if DoesEntityExist(data.entity) then
                DeleteEntity(data.entity)
            end
            playerBackWeapons[src][i] = nil
            return { action = "detached" }
        end
    end
    
    local freeSlot = -1
    local usedSlots = {}
    for i, data in pairs(playerBackWeapons[src]) do
        usedSlots[data.backSlot] = true
    end
    
    for i = 1, Config.maxSlots do
        if not usedSlots[i] then
            freeSlot = i
            break
        end
    end
    
    if freeSlot == -1 then
        return { action = "full" }
    end
    
    print("[weaponback] free slot found:", freeSlot)
    
    print("[weaponback] creating object model:", model, "at coords:", coords)
    local entity = CreateObject(model, coords.x, coords.y, coords.z, true, true, false)
    local attempts = 0
    while not DoesEntityExist(entity) and attempts < 50 do
        Wait(50)
        attempts = attempts + 1
    end
    
    if not DoesEntityExist(entity) then
        print("[weaponback] failed to create entity")
        return { action = "error" }
    end
    
    print("[weaponback] entity created successfully:", entity)
    
    local state = Entity(entity).state
    state:set("cubxWeaponBack", {
        owner = tonumber(src),
        weapon = itemName,
        model = model,
        back = freeSlot
    }, true)
    
    print("[weaponback] statebag assigned to entity")
    
    table.insert(playerBackWeapons[src], {
        entity = entity,
        itemSlot = itemSlot,
        weaponName = itemName,
        backSlot = freeSlot
    })
    
    return { action = "attached", back = freeSlot }
end)

AddEventHandler("playerDropped", function()
    local src = source
    if playerBackWeapons[src] then
        for i, data in pairs(playerBackWeapons[src]) do
            if DoesEntityExist(data.entity) then
                DeleteEntity(data.entity)
            end
        end
        playerBackWeapons[src] = nil
    end
end)