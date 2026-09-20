local provider = {
    name = 'quasar_v3',
    resource = 'qs-smartphone',
    capabilities = {
        open = true,
        appRegistration = true,
        calls = true,
        dynamicIsland = true,
        notifications = true,
        phoneEvents = true,
        number = true,
        contacts = false,
        messages = false,
        bills = false,
        mail = false,
    },
}

local function invoke(method, ...)
    local arguments = { ... }
    local ok, first, second = pcall(function()
        return exports['qs-smartphone'][method](table.unpack(arguments))
    end)
    if not ok then return false, second or first end
    return first, second
end

function provider:getNumber()
    local data = ViceCity.Framework.GetPlayerData() or {}
    local character = data.charinfo or data
    return character.phone or character.phoneNumber
end

function provider:setNumber(_, number)
    return false, { reason = 'provider_managed', provider = self.name }
end

function provider:numberExists(number)
    return false, { reason = 'provider_managed', provider = self.name, number = number }
end

function provider:open()
    ExecuteCommand('phone:toggle')
    return true
end

function provider:close()
    if self:isOpen() then ExecuteCommand('phone:toggle') end
    return true
end

function provider:toggle()
    ExecuteCommand('phone:toggle')
    return true
end

function provider:isOpen()
    local result = invoke('IsPhoneOpen')
    return result == true
end

function provider:reload()
    return false, { reason = 'unsupported', operation = 'reload', provider = self.name }
end

function provider:openApp(appId)
    return invoke('OpenPhoneApp', appId)
end

function provider:registerApp(app)
    return invoke('addCustomApp', app)
end

function provider:updateApp(appId, patch)
    return invoke('updateCustomApp', appId, patch)
end

function provider:removeApp(appId)
    return invoke('removeCustomApp', appId)
end

function provider:getApps()
    return invoke('getCustomApps')
end

function provider:startCall(number, callType)
    return invoke('call', number, callType or 'audio')
end

function provider:showDynamicIsland(data)
    return invoke('showDynamicIsland', data)
end

function provider:updateDynamicIsland(id, data)
    return invoke('updateDynamicIsland', id, data)
end

function provider:hideDynamicIsland(id)
    return invoke('hideDynamicIsland', id)
end

function provider:getDynamicIsland(id)
    return invoke('getDynamicIsland', id)
end

function provider:getAllDynamicIslands()
    return invoke('getAllDynamicIslands')
end

function provider:hasDynamicIsland()
    return invoke('hasDynamicIsland')
end

function provider:sendNotification(data)
    return false, { reason = 'server_operation', operation = 'sendNotification', provider = self.name }
end

function provider:getRaw()
    return exports['qs-smartphone']
end

ViceCity.RegisterProvider('phone', 'quasar_v3', provider)
