local provider = {
    name = 'quasar_v3',
    resource = 'qs-smartphone',
    capabilities = {
        number = true,
        notifications = true,
        bills = true,
        messages = true,
        mail = true,
        duty = true,
        calls = true,
        phoneEvents = true,
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

local function frameworkNumber(source)
    local data = ViceCity.Framework.GetPlayer(source)
    local character = data and data.character or {}
    return character.phone
end

function provider:getNumber(source)
    local number = invoke('GetCurrentPhoneNumber', source)
    return number or frameworkNumber(source)
end

function provider:setNumber()
    return false, 'provider_managed'
end

function provider:numberExists()
    return false, 'provider_managed'
end

function provider:getOwner(number)
    return false, { reason = 'unsupported', number = number, provider = self.name }
end

function provider:generateNumber()
    return false, 'provider_managed'
end

function provider:sendNotification(source, data)
    return invoke('sendPhoneNotification', source, data)
end

function provider:sendNotificationToScope(scopeId, data)
    return invoke('sendPhoneNotificationToScope', scopeId, data)
end

function provider:createBill(source, data)
    return invoke('CreateBill', source, data)
end

function provider:getBills(source)
    return invoke('GetBills', source)
end

function provider:payBill(source, billId)
    return invoke('PayBill', source, billId)
end

function provider:getMail(source)
    return invoke('GetMailAccount', source)
end

function provider:sendMail(source, subject, body)
    return invoke('SendMail', source, subject, body)
end

function provider:getConversations(source)
    return invoke('GetMessageConversations', source)
end

function provider:getUnreadMessages(source)
    return invoke('GetMessageUnreadCount', source)
end

function provider:getThreadMessages(source, threadId)
    return invoke('GetThreadMessages', source, threadId)
end

function provider:sendMessage(source, title, message)
    return invoke('SendNewMessageFromApp', source, title, message)
end

function provider:isPlayerInCall(source)
    return invoke('isPlayerInCall', source)
end

function provider:getActiveCall(source)
    return invoke('getActiveCallSession', source)
end

function provider:endCall(source)
    return invoke('endCallBySource', source)
end

function provider:registerCallInterceptor(number, handler)
    return invoke('registerCallInterceptor', number, handler)
end

function provider:unregisterCallInterceptor(number)
    return invoke('unregisterCallInterceptor', number)
end

function provider:setDuty(source, job)
    return invoke('SetDuty', source, job)
end

function provider:getDutyJob(source)
    return invoke('GetDutyJob', source)
end

function provider:jobExists(job)
    return invoke('JobExists', job)
end

function provider:isJobOnDuty(job)
    return invoke('IsJobOnDuty', job)
end

function provider:getRaw()
    return exports['qs-smartphone']
end

ViceCity.RegisterProvider('phone', 'quasar_v3', provider)
