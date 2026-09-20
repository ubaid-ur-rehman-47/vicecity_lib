ViceCityCreateAppearanceProvider('qf', 'qf_skinmenu', {
    open = function()
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
        return true
    end,
    persistence = true,
})
