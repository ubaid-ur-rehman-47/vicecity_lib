ViceCityCreateClientPhoneProvider('lb', 'lb-phone', {
    capabilities = { number = true, reload = true },
    reload = function() return exports['lb-phone']:ReloadPhone() end,
})
