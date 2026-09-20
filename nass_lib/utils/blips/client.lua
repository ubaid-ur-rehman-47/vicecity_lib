nass.createdBlips = {}

function nass.createBlip(options)
    if not options then return end
    if not options.sprite or options.radius then return end
    if not options.coords then return end
    if options.radius and not type(options.radius) == 'number' then return end
    if options.sprite and not type(options.sprite) == 'number' then return end
    local blipType = options.sprite and 'sprite' or options.radius and 'radius'

    if not blipType then return end

    if options.randomize and options.randomizeAmt then
        options.coords = vector3(options.coords.x + randomizeAmt, options.coords.y + randomizeAmt, options.coords.z)
    end

    local blip

    if blipType == 'sprite' then blip = AddBlipForCoord(options.coords.x, options.coords.y, options.coords.z) else blip = AddBlipForRadius(options.coords, options.radius) end

    if options.alpha and type(options.alpha) == 'number' then
        SetBlipAlpha(blip, options.alpha)
    end
    if options.category and type(options.category) == 'number' then
        SetBlipCategory(blip, options.category)
    end

    SetBlipDisplay(blip, 2)

    if options.sprite and type(options.sprite) == 'number' then
        SetBlipSprite(blip, options.sprite)
    end
    if options.scale and type(options.scale) == 'number' then
        SetBlipScale(blip, options.scale)
    end
    if options.shortrange and type(options.shortrange) == 'boolean' then
        SetBlipAsShortRange(blip, options.shortrange)
    end
    if options.color and type(options.color) == 'number' then
        SetBlipColour(blip, options.color)
    end

    if options.label and type(options.label) == 'string' then
        AddTextEntry('blipTitle', options.label)
        BeginTextCommandSetBlipName('blipTitle')
        EndTextCommandSetBlipName(blip)
    end
    if GetInvokingResource() ~= nil then
        if not nass.createdBlips[GetInvokingResource()] then
            nass.createdBlips[GetInvokingResource()] = {}
        end
        table.insert(nass.createdBlips[GetInvokingResource()], blip)
    end
    return blip
end

AddEventHandler('onResourceStop', function(resourceName)
	if nass.createdBlips[resourceName] then 
		for k, v in pairs(nass.createdBlips[resourceName]) do
			RemoveBlip(v)
		end
		nass.createdBlips[resourceName] = {}
	end
end)