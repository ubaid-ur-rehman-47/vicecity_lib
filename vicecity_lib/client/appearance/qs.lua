ViceCityCreateAppearanceProvider('qs', 'qs-appearance', {
    open = function()
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
        return true
    end,
    persistence = true,
})
