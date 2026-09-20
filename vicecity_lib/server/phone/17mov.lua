ViceCityCreateServerPhoneProvider('17mov', '17mov_Phone', {
    capabilities = { number = true },
    getNumber = function(_, source)
        return exports['17mov_Phone']:GetNumberFromPlayer(source)
    end,
    generateNumber = function()
        return exports['17mov_Phone']:GeneratePhoneNumber()
    end,
})
