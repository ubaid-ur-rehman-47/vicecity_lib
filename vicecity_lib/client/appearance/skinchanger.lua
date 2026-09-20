ViceCityCreateAppearanceProvider('skinchanger', 'skinchanger', {
    open = function()
        TriggerEvent('esx_skin:openSaveableMenu')
        return true
    end,
    persistence = true,
})
