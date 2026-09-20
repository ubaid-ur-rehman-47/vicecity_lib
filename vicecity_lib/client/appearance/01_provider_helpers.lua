local function providerCall(resource, method, ...)
    if GetResourceState(resource) ~= 'started' then return false end
    local arguments = { ... }
    local ok, result = pcall(function()
        return exports[resource][method](table.unpack(arguments))
    end)
    if not ok then return false end
    return result
end

local function createProvider(name, resource, options)
    options = options or {}
    local provider = {
        name = name,
        resource = resource,
        capabilities = {
            snapshot = true,
            components = true,
            props = true,
            hair = true,
            faceFeatures = true,
            overlays = true,
            model = true,
            wardrobe = true,
            persistence = options.persistence == true,
        },
    }

    function provider:get(ped)
        local value = options.get and options.get(self, ped)
        if value then return value end
        return ViceCityAppearanceNativeSnapshot(ped)
    end

    function provider:getRaw(ped)
        return self:get(ped)
    end

    function provider:set(ped, appearance)
        if options.set and ViceCityConfig.appearance.applyMode ~= 'native' then
            local result = options.set(self, ped, appearance)
            if result then return result end
        end
        return ViceCityAppearanceApplyNative(ped, appearance)
    end

    function provider:getComponent(ped, component)
        local appearance = self:get(ped)
        return appearance.components and appearance.components[component]
    end

    function provider:setComponent(ped, component, drawable, texture, palette)
        SetPedComponentVariation(ped or PlayerPedId(), component, drawable, texture or 0, palette or 0)
        return true
    end

    function provider:getProp(ped, prop)
        local appearance = self:get(ped)
        return appearance.props and appearance.props[prop]
    end

    function provider:setProp(ped, prop, drawable, texture)
        ped = ped or PlayerPedId()
        if drawable == nil or drawable < 0 then
            ClearPedProp(ped, prop)
        else
            SetPedPropIndex(ped, prop, drawable, texture or 0, true)
        end
        return true
    end

    function provider:getHair(ped)
        local appearance = self:get(ped)
        return appearance.hair
    end

    function provider:setHair(ped, hair)
        ped = ped or PlayerPedId()
        SetPedComponentVariation(ped, 2, hair.style or 0, hair.texture or 0, 0)
        SetPedHairColor(ped, hair.color or 0, hair.highlight or 0)
        return true
    end

    function provider:setModel(model, appearance)
        local native = ViceCity.Providers.appearance.native
        return native and native.setModel(native, model, appearance)
    end

    function provider:save(appearance)
        if options.save then return options.save(self, appearance) end
        return false, { reason = 'provider_event_only', provider = self.name }
    end

    function provider:load()
        return self:get()
    end

    function provider:openWardrobe()
        if options.open then return options.open(self) end
        return false, { reason = 'unsupported', operation = 'openWardrobe', provider = self.name }
    end

    ViceCity.RegisterProvider('appearance', name, provider)
end

ViceCityAppearanceProviderCall = providerCall
ViceCityCreateAppearanceProvider = createProvider
