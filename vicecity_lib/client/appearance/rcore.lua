ViceCityCreateAppearanceProvider('rcore', 'rcore_clothing', {
    open = function()
        return ViceCityAppearanceProviderCall('rcore_clothing', 'openChangingRoom')
            or ViceCityAppearanceProviderCall('rcore_clothing', 'openOutfitMenu')
            or false
    end,
    persistence = true,
})
