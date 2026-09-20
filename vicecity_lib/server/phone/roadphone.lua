ViceCityCreateServerPhoneProvider('roadphone', 'roadphone', {
    capabilities = { number = true },
    getNumber = function(_, source)
        local identifier = ViceCity.Framework.GetIdentifier(source)
        return identifier and exports.roadphone:getNumberFromIdentifier(identifier) or nil
    end,
})
