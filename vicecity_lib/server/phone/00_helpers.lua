local function createServerPhoneProvider(name, resource, options)
    options = options or {}
    local provider = {
        name = name,
        resource = resource,
        capabilities = options.capabilities or { number = true },
    }

    local function invoke(method, ...)
        local arguments = { ... }
        local ok, first, second = pcall(function()
            return exports[resource][method](table.unpack(arguments))
        end)
        if not ok then return false, second or first end
        return first, second
    end

    function provider:getNumber(source)
        if options.getNumber then return options.getNumber(self, source) end
        local data = ViceCity.Framework.GetPlayer(source)
        local character = data and data.character or {}
        return character.phone
    end

    function provider:setNumber(source, number)
        if options.setNumber then return options.setNumber(self, source, number) end
        return false, 'unsupported'
    end

    function provider:numberExists(number)
        if options.numberExists then return options.numberExists(self, number) end
        return false, 'unsupported'
    end

    function provider:generateNumber()
        if options.generateNumber then return options.generateNumber(self) end
        return false, 'unsupported'
    end

    function provider:getOwner(number)
        if options.getOwner then return options.getOwner(self, number) end
        return false, 'unsupported'
    end

    function provider:sendNotification(source, data)
        if options.sendNotification then return options.sendNotification(self, source, data) end
        return false, 'unsupported'
    end

    function provider:getBills(source)
        if options.getBills then return options.getBills(self, source) end
        return false, 'unsupported'
    end

    function provider:createBill(source, data)
        if options.createBill then return options.createBill(self, source, data) end
        return false, 'unsupported'
    end

    function provider:sendMessage(source, title, message)
        if options.sendMessage then return options.sendMessage(self, source, title, message) end
        return false, 'unsupported'
    end

    function provider:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('phone', name, provider)
end

ViceCityCreateServerPhoneProvider = createServerPhoneProvider
