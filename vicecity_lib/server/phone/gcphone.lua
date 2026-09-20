ViceCityCreateServerPhoneProvider('gcphone', 'gcphone', {
    capabilities = { number = true },
    getNumber = function(_, source)
        return exports.gcphone:getPhoneNumber(source)
    end,
})
