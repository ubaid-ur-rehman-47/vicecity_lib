ViceCityCreateAppearanceProvider('0r', '0r-clothing', {
    open = function()
        TriggerEvent('qb-clothing:client:openOutfitMenu')
        return true
    end,
    persistence = true,
})
