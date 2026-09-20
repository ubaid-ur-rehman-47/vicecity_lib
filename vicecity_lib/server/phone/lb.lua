ViceCityCreateServerPhoneProvider('lb', 'lb-phone', {
    capabilities = { number = true, notifications = true },
    getNumber = function(_, source)
        return exports['lb-phone']:GetEquippedPhoneNumber(source)
    end,
    sendNotification = function(_, source, data)
        return exports['lb-phone']:SendNotification(source, data)
    end,
})
