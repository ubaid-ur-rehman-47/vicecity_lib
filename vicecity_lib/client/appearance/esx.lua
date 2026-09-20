ViceCityCreateAppearanceProvider('esx', 'esx_skin', {
    open = function()
        TriggerEvent('esx_skin:openSaveableMenu')
        return true
    end,
    save = function()
        TriggerEvent('esx_skin:requestSaveSkin')
        return true
    end,
    persistence = true,
})
