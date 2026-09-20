ViceCityCreateServerPhoneProvider('codem', 'codem-phone', {
    capabilities = { number = true, notifications = true },
    getNumber = function(_, source)
        local ok, number = pcall(function() return exports['codem-phone']:GetPhoneNumberBySource(source) end)
        if ok and number then return number end
        local identifier = ViceCity.Framework.GetIdentifier(source)
        return identifier and exports['codem-phone']:GetPhoneNumberByIdentifier(identifier) or nil
    end,
    sendNotification = function(_, source, data)
        return exports['codem-phone']:SendNotification(source, data)
    end,
})
