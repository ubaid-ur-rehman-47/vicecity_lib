if GetResourceState('ox_target') ~= 'started' then return end
nass.targetSystem = 'ox_target'

nass.target = {}
ActiveTargets = {}

local function convertOptions(options, identifier, targetType)
    local newOptions = {}
    for _, option in ipairs(options) do
        newOptions[#newOptions + 1] = {
            name = targetType ~= nil and targetType .. '_' .. identifier or identifier,
            groups = option.groups or option.job or option.gang or false,
            distance = option.distance,
        }
        for optionName, optionValue in pairs(option) do
            newOptions[#newOptions][optionName] = optionValue
        end
    end
    return newOptions
end

function nass.target.addBoxZone(coords, heading, size, _distance, options, compatibilityIdentifier)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end

    for k, v in pairs(options) do
        if v?.gang then
            v.groups = v.gang
        end
    end

    local identifier
    if compatibilityIdentifier then
        exports.ox_target:addBoxZone({
            name = compatibilityIdentifier,
            coords = coords,
            size = size,
            rotation = heading,
            options = options,
        })
        identifier = compatibilityIdentifier
    else
        identifier = exports.ox_target:addBoxZone({
            coords = coords,
            size = size,
            rotation = heading,
            options = options,
        })
    end
    SaveTargetOptions('boxZone', invokingResource, identifier, options)

    return identifier
end

function nass.target.localEntity(entities, data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('entity', invokingResource)
    local currentOptions = convertOptions(data, identifier, 'entity')
    SaveTargetOptions('entity', invokingResource, identifier, currentOptions)
    exports.ox_target:addLocalEntity(entities, currentOptions)
    return 'entity_' .. identifier
end

function nass.target.player(data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('player', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'player')
    SaveTargetOptions('player', invokingResource, identifier, currentOptions)
    exports.ox_target:addGlobalPlayer(currentOptions)
    return 'player_' .. identifier
end

function nass.target.vehicle(data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('vehicle', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'vehicle')
    SaveTargetOptions('vehicle', invokingResource, identifier, currentOptions)
    exports.ox_target:addGlobalVehicle(currentOptions)
    return 'vehicle_' .. identifier
end

function nass.target.model(models, data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('model', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'model')
    SaveTargetOptions('model', invokingResource, identifier, currentOptions, { models = models })
    exports.ox_target:addModel(models, currentOptions)
    return 'model_' .. identifier
end

function nass.target.bone(bones, data)
    local invokingResource = GetInvokingResource()
    if not invokingResource then return end
    local identifier = GenerateTargetIdentifier('bone', invokingResource)
    local currentOptions = convertOptions(data.options, identifier, 'bone')
    for _, option in ipairs(currentOptions) do
        option.bones = bones
    end
    SaveTargetOptions('bone', invokingResource, identifier, currentOptions)
    exports.ox_target:addGlobalVehicle(currentOptions)
    return 'bone_' .. identifier
end

function nass.target.removeTarget(id)
    if not id then return end
    if string.sub(id, 1, 7) == 'player_' then
        exports.ox_target:removeGlobalPlayer(id)
        return
    end
    if string.sub(id, 1, 8) == 'vehicle_' then
        exports.ox_target:removeGlobalVehicle(id)
        return
    end
    if string.sub(id, 1, 6) == 'model_' then
        exports.ox_target:removeModel(id)
        return
    end
    if string.sub(id, 1, 5) == 'bone_' then
        exports.ox_target:removeGlobalVehicle(id)
        return
    end
    if string.sub(id, 1, 7) == 'entity_' then
        exports.ox_target:removeLocalEntity(tonumber(string.sub(id, 8)))
        return
    end

    exports.ox_target:removeZone(id, true)
end

local function resourceStopped(resource)
    for targetType, targets in pairs(ActiveTargets) do
        for resourceName, targetData in pairs(targets) do
            if resourceName == resource then
                local names = {}
                for _, target in ipairs(targetData) do
                    for _, option in ipairs(target.options) do
                        names[#names + 1] = option.name
                    end
                    if targetType == 'player' then
                        exports.ox_target:removeGlobalPlayer(names)
                    elseif targetType == 'vehicle' or targetType == 'bone' then
                        exports.ox_target:removeGlobalVehicle(names)
                    elseif targetType == 'model' then
                        exports.ox_target:removeModel(targetData.models, names)
                    elseif targetType == 'entity' then
                        exports.ox_target:removeLocalEntity(target.identifier)
                    else
                        exports.ox_target:removeZone(target.identifier, true)
                    end
                end
            end
            ActiveTargets[targetType][resourceName] = nil
        end
    end
end

AddEventHandler('onResourceStop', function(resource) resourceStopped(resource) end)