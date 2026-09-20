ViceCityCreateAppearanceProvider('codem', 'codem-clothing', {
    open = function()
        TriggerEvent('codem-clothing:client:openOutfitMenu')
        return true
    end,
    persistence = true,
})
