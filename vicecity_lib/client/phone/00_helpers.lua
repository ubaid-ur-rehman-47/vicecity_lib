local function phoneUnsupported(operation, provider)
    return false, { reason = 'unsupported', operation = operation, provider = provider }
end

local function createClientPhoneProvider(name, resource, options)
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

    function provider:getNumber()
        local data = ViceCity.Framework.GetPlayerData() or {}
        local character = data.charinfo or data
        return character.phone or character.phoneNumber
    end

    function provider:setNumber()
        return phoneUnsupported('setNumber', self.name)
    end

    function provider:numberExists()
        return phoneUnsupported('numberExists', self.name)
    end

    function provider:generateNumber()
        return phoneUnsupported('generateNumber', self.name)
    end

    function provider:open()
        if options.open then return options.open(self) end
        return phoneUnsupported('open', self.name)
    end

    function provider:close()
        if options.close then return options.close(self) end
        return phoneUnsupported('close', self.name)
    end

    function provider:toggle()
        if options.toggle then return options.toggle(self) end
        return phoneUnsupported('toggle', self.name)
    end

    function provider:isOpen()
        if options.isOpen then return options.isOpen(self) end
        return false
    end

    function provider:reload()
        if options.reload then return options.reload(self) end
        return phoneUnsupported('reload', self.name)
    end

    function provider:openApp(appId)
        if options.openApp then return options.openApp(self, appId) end
        return phoneUnsupported('openApp', self.name)
    end

    function provider:startCall(number, callType)
        if options.startCall then return options.startCall(self, number, callType) end
        return phoneUnsupported('startCall', self.name)
    end

    function provider:getActiveDevice()
        return phoneUnsupported('getActiveDevice', self.name)
    end

    function provider:setActivePhone()
        return phoneUnsupported('setActivePhone', self.name)
    end

    function provider:getRaw()
        return resource and exports[resource] or nil
    end

    ViceCity.RegisterProvider('phone', name, provider)
end

ViceCityCreateClientPhoneProvider = createClientPhoneProvider
ViceCityPhoneUnsupported = phoneUnsupported
