ViceCityCreateServerPhoneProvider('sd', 'sd-phone', {
    capabilities = { number = true },
    getNumber = function(_, source)
        return exports['sd-phone']:getPhoneNumber(source)
    end,
})
