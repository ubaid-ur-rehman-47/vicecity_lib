ViceCityCreateAppearanceProvider('illenium', 'illenium-appearance', {
    get = function(_, ped) return ViceCityAppearanceProviderCall('illenium-appearance', 'getPedAppearance',
            ped or PlayerPedId()) end,
    set = function(_, ped, appearance) return ViceCityAppearanceProviderCall('illenium-appearance', 'setPedAppearance',
            ped or PlayerPedId(), appearance) end,
    save = function()
        TriggerEvent('illenium-appearance:client:saveAppearance')
        return true
    end,
    open = function()
        TriggerEvent('illenium-appearance:client:openOutfitMenu')
        return true
    end,
    persistence = true,
})
