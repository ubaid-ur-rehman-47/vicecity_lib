ViceCityCreateAppearanceProvider('crm', 'crm-appearance', {
    open = function()
        return ViceCityAppearanceProviderCall('crm-appearance', 'crm_open_outfits') or false
    end,
    persistence = true,
})
