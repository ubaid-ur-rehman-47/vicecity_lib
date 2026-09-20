ViceCity.Phone = ViceCity.Phone or {}

local function adapter()
    return ViceCity.PhoneAdapter
end

local function call(name, ...)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.GetProvider('phone') }
    end
    local ok, first, second = pcall(method, provider, ...)
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(first) }
    end
    return first, second
end

function ViceCity.Phone.GetProvider()
    return ViceCity.GetProvider('phone') or 'none'
end

function ViceCity.Phone.GetCapabilities()
    local provider = adapter()
    return provider and provider.capabilities or {}
end

function ViceCity.Phone.GetNumber(source)
    return call('getNumber', source)
end

function ViceCity.Phone.SetNumber(source, number)
    return call('setNumber', source, number)
end

function ViceCity.Phone.NumberExists(number)
    return call('numberExists', number)
end

function ViceCity.Phone.GenerateNumber()
    return call('generateNumber')
end

function ViceCity.Phone.GetOwner(number)
    return call('getOwner', number)
end

function ViceCity.Phone.Open()
    return call('open')
end

function ViceCity.Phone.Close()
    return call('close')
end

function ViceCity.Phone.Toggle()
    return call('toggle')
end

function ViceCity.Phone.IsOpen()
    return call('isOpen')
end

function ViceCity.Phone.Reload()
    return call('reload')
end

function ViceCity.Phone.GetActiveDevice(source)
    return call('getActiveDevice', source)
end

function ViceCity.Phone.SetActivePhone(source, phoneId)
    return call('setActivePhone', source, phoneId)
end

function ViceCity.Phone.OpenApp(appId)
    return call('openApp', appId)
end

function ViceCity.Phone.RegisterApp(app)
    return call('registerApp', app)
end

function ViceCity.Phone.UpdateApp(appId, patch)
    return call('updateApp', appId, patch)
end

function ViceCity.Phone.RemoveApp(appId)
    return call('removeApp', appId)
end

function ViceCity.Phone.GetApps()
    return call('getApps')
end

function ViceCity.Phone.ShowDynamicIsland(data)
    return call('showDynamicIsland', data)
end

function ViceCity.Phone.UpdateDynamicIsland(id, data)
    return call('updateDynamicIsland', id, data)
end

function ViceCity.Phone.HideDynamicIsland(id)
    return call('hideDynamicIsland', id)
end

function ViceCity.Phone.GetDynamicIsland(id)
    return call('getDynamicIsland', id)
end

function ViceCity.Phone.GetDynamicIslands()
    return call('getAllDynamicIslands')
end

function ViceCity.Phone.HasDynamicIsland()
    return call('hasDynamicIsland')
end

function ViceCity.Phone.StartCall(number, callType)
    return call('startCall', number, callType)
end

function ViceCity.Phone.SendMessage(title, message, options)
    return call('sendMessage', title, message, options)
end

function ViceCity.Phone.SendNotification(source, data)
    if data == nil then data, source = source, nil end
    return call('sendNotification', source, data)
end

function ViceCity.Phone.GetBills(source)
    return call('getBills', source)
end

function ViceCity.Phone.CreateBill(source, data)
    return call('createBill', source, data)
end

function ViceCity.Phone.PayBill(source, billId)
    return call('payBill', source, billId)
end

function ViceCity.Phone.GetMail(source)
    return call('getMail', source)
end

function ViceCity.Phone.SendMail(source, subject, body)
    return call('sendMail', source, subject, body)
end

function ViceCity.Phone.GetMessageConversations(source)
    return call('getConversations', source)
end

function ViceCity.Phone.GetUnreadMessages(source)
    return call('getUnreadMessages', source)
end

function ViceCity.Phone.GetThreadMessages(source, threadId)
    return call('getThreadMessages', source, threadId)
end

function ViceCity.Phone.IsPlayerInCall(source)
    return call('isPlayerInCall', source)
end

function ViceCity.Phone.GetActiveCall(source)
    return call('getActiveCall', source)
end

function ViceCity.Phone.EndCall(source)
    return call('endCall', source)
end

function ViceCity.Phone.RegisterCallInterceptor(number, handler)
    return call('registerCallInterceptor', number, handler)
end

function ViceCity.Phone.UnregisterCallInterceptor(number)
    return call('unregisterCallInterceptor', number)
end

function ViceCity.Phone.SetDuty(source, job)
    return call('setDuty', source, job)
end

function ViceCity.Phone.GetDutyJob(source)
    return call('getDutyJob', source)
end

function ViceCity.Phone.GetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end

GetPhoneNumber = ViceCity.Phone.GetNumber
SetPhoneNumber = ViceCity.Phone.SetNumber
GetPhoneProvider = ViceCity.Phone.GetProvider
GetPhoneCapabilities = ViceCity.Phone.GetCapabilities
