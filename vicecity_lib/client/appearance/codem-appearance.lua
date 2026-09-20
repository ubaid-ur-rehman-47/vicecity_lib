ViceCityCreateAppearanceProvider('codemAppearance', 'codem-appearance', {
    open = function()
        TriggerEvent('codem-apperance:OpenWardrobe')
        return true
    end,
    persistence = true,
})
