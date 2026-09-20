ViceCityCreateAppearanceProvider('qb', 'qb-clothing', {
    open = function()
        TriggerEvent('qb-clothing:client:openOutfitMenu')
        return true
    end,
    save = function()
        TriggerEvent('qb-clothing:client:saveOutfit')
        return true
    end,
    persistence = true,
})
