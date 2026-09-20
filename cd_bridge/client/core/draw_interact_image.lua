local images = {}
local registeredInteracts = {}
local tempInteracts = {}
local hudVisibility = true

Wait(2000)
SendNUIMessage({
    action = 'get_interact_images',
    options = {
        background = '#031633',
        border = '#084298',
        color = '#6ea8fe',
        key = 'E',
    },
    unique_id = '1'
})

local txd = CreateRuntimeTxd('cd_interact_txd')

RegisterNuiCallback('interact_images', function(data, cb)
    for k, v in ipairs(data.images) do
        CreateRuntimeTextureFromImage(txd, 'interact_'..k, v)
        table.insert(images, 'interact_'..k)
    end
    cb('ok')
end)

RegisterNetEvent('cd_bridge:HudVisibilityChanged', function(state)
    hudVisibility = state
end)

local function getScaleByDistance(distance, minDist, maxDist, minScale, maxScale)
    distance = math.max(minDist, math.min(maxDist, distance))
    local normalized = (distance - minDist) / (maxDist - minDist)
    return maxScale + (minScale - maxScale) * normalized
end

local function remap(value, fromMin, fromMax, toMin, toMax)
    local t = (value - fromMin) / (fromMax - fromMin)
    t = math.max(0, math.min(1, t))
    return toMin + t * (toMax - toMin)
end

RegisterNetEvent('cd_bridge:DrawInteractImage:Add', function(resourceName, interact)
    if not resourceName or not interact or not interact.unique_id then return end
    registeredInteracts[resourceName] = registeredInteracts[resourceName] or {}
    for i = 1, #registeredInteracts[resourceName] do
        if registeredInteracts[resourceName][i].unique_id == interact.unique_id then
            registeredInteracts[resourceName][i] = interact
            return
        end
    end

    registeredInteracts[resourceName][#registeredInteracts[resourceName] + 1] = interact
end)

RegisterNetEvent('cd_bridge:DrawInteractImage:Remove', function(resourceName, interactId)
    if not resourceName or not interactId or not registeredInteracts[resourceName] then return end

    for i = #registeredInteracts[resourceName], 1, -1 do
        if registeredInteracts[resourceName][i].unique_id == interactId then
            table.remove(registeredInteracts[resourceName], i)
            return
        end
    end
end)

RegisterNetEvent('cd_bridge:DrawInteractImage:ClearAll', function(resourceName)
    if resourceName then
        registeredInteracts[resourceName] = {}
    else
        registeredInteracts = {}
    end
end)

AddEventHandler('onClientResourceStop', function(resourceName)
    if registeredInteracts[resourceName] then
        registeredInteracts[resourceName] = nil
    end
end)


CreateThread(function()
    Wait(3000)

    local function isFunctionReference(value)
        return type(value) == 'table' and value.__cfx_functionReference ~= nil
    end

    while true do
        local wait = 1000
        local aspect_ratio = 1 / GetAspectRatio(false)

        local ped = PlayerPedId()
        local ped_coords = GetEntityCoords(ped)

        for _, locations in pairs(registeredInteracts) do
            for i = 1, #locations do
                local data = locations[i]

                if data and data.coords and hudVisibility then
                    local distance = #(ped_coords - data.coords)
                    local zDistance = math.abs(ped_coords.z - data.coords.z)
                    if distance <= data.view_distance and zDistance <= 1.5 then
                        wait = 0

                        local canInteract = true

                        if data.canInteract then
                            local success, result = pcall(data.canInteract)
                            canInteract = success and result == true
                        end

                        if canInteract then
                            if Cfg.Debug then
                                DrawMarker(28, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, data.view_distance + 0.0, data.view_distance + 0.0, data.view_distance + 0.0, 255, 0, 0, 80, false, false, 2, false, nil, nil, false)
                                DrawMarker(28, data.coords.x, data.coords.y, data.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, data.interact_distance + 0.0, data.interact_distance + 0.0, data.interact_distance + 0.0, 255, 255, 0, 80, false, false, 2, false, nil, nil, false)
                            end

                            SetDrawOrigin(data.coords.x, data.coords.y, data.coords.z)

                            local scale = getScaleByDistance(distance, 0, data.view_distance, 0.02, 0.07)

                            if images and #images > 0 then
                                local idx

                                if distance <= data.interact_distance then
                                    local index = remap(distance / data.interact_distance, 0, 1, 1, 9)
                                    idx = math.ceil(index)
                                else
                                    local outsideDistance = distance - data.interact_distance
                                    local outsideRange = data.view_distance - data.interact_distance

                                    if outsideRange <= 0 then
                                        idx = 10
                                    else
                                        local index = remap(outsideDistance / outsideRange, 0, 1, 10, 17)
                                        idx = math.ceil(index)
                                    end
                                end

                                if idx > 17 then
                                    idx = 17
                                elseif idx < 1 then
                                    idx = 1
                                end

                                if images[idx] then
                                    DrawSprite('cd_interact_txd', images[idx], 0.0, 0.0, scale * aspect_ratio, scale, 0, 255, 255, 255, 255)
                                end
                            end

                            if distance <= data.interact_distance and data.action then
                                if IsControlJustReleased(0, data.key or 38) then
                                    if type(data.action) == 'function' or isFunctionReference(data.action) then
                                        data.action(data.action_return_data)

                                    elseif type(data.action) == 'table' then
                                        if data.action.type == 'client_event' then
                                            TriggerEvent(data.action.event, data)
                                        elseif data.action.type == 'server_event' then
                                            TriggerServerEvent(data.action.event, data)
                                        end
                                    end
                                end
                            end

                            ClearDrawOrigin()
                        end
                    end
                end
            end
        end

        Wait(wait)
    end
end)

RegisterNetEvent('cd_bridge:DrawInteractImage:Stop', function(unique_id)
    if unique_id then
        if tempInteracts[unique_id] then
            tempInteracts[unique_id] = nil
        end
    else
        tempInteracts = {}
    end
end)

function StartTempDrawInteractImage(data)
    local uniqueID = data.unique_id or ('temp_' .. GenerateUniqueId(12))
    tempInteracts[uniqueID] = data

    local ped = PlayerPedId()

    while tempInteracts[uniqueID] do
        Wait(0)

        local aspect_ratio = 1 / GetAspectRatio(false)
        local ped_coords = GetEntityCoords(ped)
        local dist_to_target = #(ped_coords - data.coords)

        if dist_to_target <= data.view_distance then
            if hudVisibility then
                SetDrawOrigin(data.coords.x, data.coords.y, data.coords.z)

                local scale = getScaleByDistance(dist_to_target, 0, data.view_distance, 0.03, 0.07)

                if images and #images > 0 then
                    local idx

                    if dist_to_target <= data.interact_distance then
                        local index = remap(dist_to_target / data.interact_distance, 0, 1, 1, 9)
                        idx = math.ceil(index)
                    else
                        local outsideDistance = dist_to_target - data.interact_distance
                        local outsideRange = data.view_distance - data.interact_distance

                        if outsideRange <= 0 then
                            idx = 10
                        else
                            local index = remap(outsideDistance / outsideRange, 0, 1, 10, 17)
                            idx = math.ceil(index)
                        end
                    end

                    if idx > 17 then
                        idx = 17
                    elseif idx < 1 then
                        idx = 1
                    end

                    if images[idx] then
                        DrawSprite('cd_interact_txd', images[idx], 0.0, 0.0, scale * aspect_ratio, scale, 0, 255, 255, 255, 255)
                    end
                end

                if dist_to_target <= data.interact_distance then
                    local key = data.key or 38

                    if IsControlJustReleased(0, key) then
                        tempInteracts[uniqueID] = nil
                        ClearDrawOrigin()
                        return true
                    end
                end

                ClearDrawOrigin()
            end
        else
            tempInteracts[uniqueID] = nil
            ClearDrawOrigin()
            return false
        end
    end

    return false
end

exports('StartTempDrawInteractImage', StartTempDrawInteractImage)

function GetInteractImageData()
    return registeredInteracts
end