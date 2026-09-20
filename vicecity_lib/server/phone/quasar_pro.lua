ViceCityCreateServerPhoneProvider('quasar_pro', 'qs-smartphone-pro', {
    capabilities = { number = true },
    getNumber = function(_, source)
        local identifier = ViceCity.Framework.GetIdentifier(source)
        if not identifier then return nil end
        local ok, number = pcall(function()
            return exports['qs-smartphone-pro']:GetPhoneNumberFromIdentifier(identifier, false)
        end)
        return ok and number or nil
    end,
})
