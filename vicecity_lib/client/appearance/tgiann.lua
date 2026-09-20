ViceCityCreateAppearanceProvider('tgiann', 'tgiann-clothing', {
    open = function()
        return ViceCityAppearanceProviderCall('tgiann-clothing', 'OpenOutfitStash') or false
    end,
    persistence = true,
})
