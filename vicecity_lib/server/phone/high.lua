ViceCityCreateServerPhoneProvider('high', 'high-phone', {
    capabilities = { number = true },
    getNumber = function(_, source)
        return exports['high-phone']:getPlayerPhoneNumber(source)
    end,
    getOwner = function(_, number)
        return exports['high-phone']:getPlayerByPhone(number)
    end,
})
