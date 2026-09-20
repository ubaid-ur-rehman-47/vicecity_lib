if GetResourceState('ox_target') == 'started' then return end
if GetResourceState('qtarget') ~= 'started' then return end
nass.targetSystem = 'qtarget'

nass.target = {}
ActiveTargets = {}

local function convertOptions(options, identifier, targetType)
    local newOptions = {}
    for _, option in ipairs(options) do
        newOptions[#newOptions + 1] = {
            name = targetType .. '_' .. identifier,
            job = option.groups or option.job or false,
            distance = option.distance,
        }
        for optionName, optionValue in pairs(option) do
            newOptions[#newOptions][optionName] = optionValue
        end
    end
    return newOptions
end

function nass.target.addBoxZone(coords, heading, size, distance, options, compatibilityIdentifier)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end

    local identifier = compatibilityIdentifier or GenerateTargetIdentifier('boxZone', invokingResource)
    local currentOptions = convertOptions(options, identifier, 'boxZone')

    SaveTargetOptions('boxZone', invokingResource, identifier, currentOptions)

    if type(identifier) == 'number' then
        identifier = 'boxZone_' .. identifier
    end

    exports.qtarget.AddBoxZone(identifier, coords, size.x, size.y, {
        name = identifier,
        heading = heading,
        debugPoly = false,
        minZ = coords.z - size.z,
        maxZ = coords.z + size.z,
        useZ = true,
    }, {
        options = currentOptions,
        distance = distance
    })
    return identifier
end

function nass.target.localEntity(entities, data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('entity', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'entity')
    SaveTargetOptions('entity', invokingResource, identifier, currentOptions)
    exports.qtarget:AddTargetEntity(entities, currentOptions)
    return 'entity_' .. identifier
end

function nass.target.player(data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('player', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'player')
    SaveTargetOptions('player', invokingResource, identifier, currentOptions)
    exports.qtarget:Player({options = currentOptions, distance = data.distance})
    return 'player_' .. identifier
end

function nass.target.vehicle(data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('vehicle', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'vehicle')
    SaveTargetOptions('vehicle', invokingResource, identifier, currentOptions)
    exports.qtarget:Vehicle({options = currentOptions, distance = data.distance})
    return 'vehicle_' .. identifier
end

function nass.target.model(models, data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('model', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'model')
    SaveTargetOptions('model', invokingResource, identifier, currentOptions, { models = models })
    exports.qtarget:AddTargetModel(models, {
        distance = data.distance,
        job = data.groups or data.job or 'all',
        options = currentOptions
    })
    return 'model_' .. identifier
end

function nass.target.bone(bones, data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('bone', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'bone')
    SaveTargetOptions('bone', invokingResource, identifier, currentOptions, { bones = bones })
    exports.qtarget:AddTargetBone(bones, {
        distance = data.distance,
        job = data.groups or data.job or 'all',
        options = currentOptions
    })
    return 'bone_' .. identifier
end

function nass.target.removeTarget(id)
    if not id then return end
    if string.sub(id, 1, 7) == 'player_' then
        exports.qtarget:RemovePlayer(id)
        return
    end
    if string.sub(id, 1, 8) == 'vehicle_' then
        exports.qtarget:RemoveVehicle(id)
        return
    end
    if string.sub(id, 1, 6) == 'model_' then
        exports.qtarget:RemoveTargetModel(id)
        return
    end
    if string.sub(id, 1, 5) == 'bone_' then
        exports.qtarget:RemoveTargetBone(id)
        return
    end
    if string.sub(id, 1, 7) == 'entity_' then
        exports.qtarget:RemoveTargetEntity(id)
        return
    end
    exports.qtarget:RemoveZone(id)
end

local function resourceStopped(resource)
    for targetType, targets in pairs(ActiveTargets) do
        for resourceName, targetData in pairs(targets) do
            if resourceName == resource then
                local names = {}
                for _, target in ipairs(targetData) do
                    for _, option in ipairs(target.options) do
                        names[#names + 1] = option.label
                    end
                    if targetType == 'player' then
                        exports.qtarget:RemovePlayer(names)
                    elseif targetType == 'vehicle' then
                        exports.qtarget:RemoveVehicle(names)
                    elseif targetType == 'model' then
                        exports.qtarget:RemoveTargetModel(targetData.models, names)
                    elseif targetType == 'bone' then
                        exports.qtarget:RemoveTargetBone(targetData.bones, names)
                    elseif targetType == 'entity' then
                        exports.qtarget:RemoveTargetEntity(target.identifier)
                    else
                        if type(target.identifier) == 'number' then
                            exports.qtarget:RemoveZone('boxZone_' .. target.identifier)
                        else
                            exports.qtarget:RemoveZone(target.identifier)
                        end

                    end
                end
            end
            ActiveTargets[targetType][resourceName] = nil
        end
    end
end

AddEventHandler('onResourceStop', function(resource) resourceStopped(resource) end)