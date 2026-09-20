function ViceCityCreateServerAppearanceProvider(name, resource, options)
    options = options or {}
    local provider = {
        name = name,
        resource = resource,
        capabilities = {
            persistence = options.persistence == true,
            playerAppearance = false,
            wardrobeEvents = options.wardrobeEvents == true,
        },
    }

    function provider:get(source)
        if options.get then return options.get(self, source) end
        return false, { reason = 'client_only', operation = 'get', provider = self.name }
    end

    function provider:set(source, appearance)
        if options.set then return options.set(self, source, appearance) end
        if source then
            TriggerClientEvent('vicecity:appearance:apply', source, appearance)
            return true
        end
        return false, { reason = 'invalid_source', provider = self.name }
    end

    function provider:save(source, appearance)
        if options.save then return options.save(self, source, appearance) end
        return false, { reason = 'provider_owned_client_event', operation = 'save', provider = self.name }
    end

    function provider:load(source)
        if options.load then return options.load(self, source) end
        return false, { reason = 'client_only', operation = 'load', provider = self.name }
    end

    function provider:openWardrobe(source)
        if options.open then return options.open(self, source) end
        if source then
            TriggerClientEvent('vicecity:appearance:openWardrobe', source)
            return true
        end
        return false, { reason = 'invalid_source', provider = self.name }
    end

    ViceCity.RegisterProvider('appearance', name, provider)
end
