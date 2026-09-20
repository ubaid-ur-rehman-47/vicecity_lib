ViceCityCreateAppearanceProvider('4bit', '4bit_appearance', {
    open = function()
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
        return true
    end,
    persistence = true,
})
