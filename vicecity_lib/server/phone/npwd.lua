ViceCityCreateServerPhoneProvider('npwd', 'npwd', {
    capabilities = { number = true },
    getNumber = function(_, source)
        local identifier = ViceCity.Framework.GetIdentifier(source)
        local data = identifier and exports.npwd:getPlayerData({ identifier = identifier })
        return data and data.phoneNumber or nil
    end,
})
