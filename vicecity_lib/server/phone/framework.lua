ViceCityCreateServerPhoneProvider('framework', nil, {
    capabilities = { number = true, framework = true },
    getNumber = function(_, source)
        local player = ViceCity.Framework.GetPlayer(source)
        local character = player and player.character or {}
        return character.phone
    end,
    setNumber = function(_, source, number)
        local raw = ViceCity.Framework.GetRawPlayer(source)
        if raw and raw.Functions and raw.Functions.SetCharInfo then
            return raw.Functions.SetCharInfo({ phone = number }) and true or false
        end
        return false, 'unsupported'
    end,
})
