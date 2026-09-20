RegisterNetEvent('vicecity:appearance:save', function(appearance)
    local source = source
    TriggerClientEvent('vicecity:appearance:apply', source, appearance)
end)

RegisterNetEvent('vicecity:appearance:openWardrobe', function()
    local source = source
    ViceCity.Wardrobe.Open(source)
end)
