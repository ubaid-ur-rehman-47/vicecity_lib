ViceCityCreateAppearanceProvider('fivem', 'fivem-appearance', {
    get = function(_, ped) return ViceCityAppearanceProviderCall('fivem-appearance', 'getPedAppearance',
            ped or PlayerPedId()) end,
    set = function(_, ped, appearance) return ViceCityAppearanceProviderCall('fivem-appearance', 'setPedAppearance',
            ped or PlayerPedId(), appearance) end,
    open = function() return ViceCityAppearanceProviderCall('fivem-appearance', 'openOutfitMenu') or false end,
    persistence = true,
})
