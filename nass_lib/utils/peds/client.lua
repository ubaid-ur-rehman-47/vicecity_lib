nass.createdPeds = {}

function nass.createPed(options, resourceName)
    if not options.model then return false end
    if not options.coords then return false end
    if not options.coords.w then return false end
    local networked = false
    if options.networked then
        networked = true
    end
    local model = options.model
	nass.loadModel(model)
    

    if not model then return false end
    local newPed = CreatePed(0, joaat(model), options.coords.x, options.coords.y, options.coords.z - 1, options.coords.w, networked, true)
    if not newPed then return false end
    
    if options.frozen then
		FreezeEntityPosition(newPed, true)
	end

	if options.invincible then
		SetEntityInvincible(newPed, true)
	end

	if options.blockNonTemp then
		SetBlockingOfNonTemporaryEvents(newPed, true)
	end

	if options.anim then
        local dict = nass.requestAnimDict(options.anim.dict)
        if dict then
            TaskPlayAnim(newPed, dict, options.anim.name, 8.0, 0, -1, 1, 0, 0, 0)
        end
	end

    if options.scenario then
        TaskStartScenarioInPlace(newPed, options.scenario, 0, true)
    end

    local resource = GetInvokingResource() and GetInvokingResource() or resourceName
    if resource ~= nil then
        if not nass.createdPeds[resource] then
            nass.createdPeds[resource] = {}
        end
        nass.createdPeds[resource][newPed] = newPed
    end
    return newPed
end

function nass.removePed(ped, resourceName)
    DeletePed(ped)
    nass.createdPeds[resourceName][ped] = nil
end

function nass.createPedAtPoint(options, resourceName)
    local point = nass.points.new({
        resource = resourceName,
        coords = options.coords,
        distance = options.distance or 50.0,
        onEnter = function()
            if not options.pedId or not DoesEntityExist(nass.createdPeds[resourceName][options.pedId]) then
                options.pedId = nass.createPed(options, resourceName)
            end
        end,
        onExit = function()
            nass.removePed(options.pedId, resourceName)
        end,
    })
    return point
end

AddEventHandler('onResourceStop', function(resourceName)
    if nass.createdPeds[resourceName] then 
		for k, v in pairs(nass.createdPeds[resourceName]) do
			nass.removePed(k, resourceName)
		end
        nass.createdPeds[resourceName] = {}
	end
end)