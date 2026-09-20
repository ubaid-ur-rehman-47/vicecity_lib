ViceCityCreateServerPhoneProvider('yseries', 'yseries', {
    capabilities = { number = true },
    getNumber = function(_, source)
        return exports.yseries:GetPhoneNumberBySourceId(source)
    end,
})
