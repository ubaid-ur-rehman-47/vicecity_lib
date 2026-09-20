ViceCityCreateServerPhoneProvider('gksphone', 'gksphone', {
    capabilities = { number = true },
    getNumber = function(_, source)
        return exports.gksphone:GetPhoneBySource(source)
    end,
    getOwner = function(_, number)
        return exports.gksphone:GetPhoneDataByNumber(number)
    end,
})
