AddEventHandler('17mov_CharacterSystem:SaveCurrentSkin', function()
    TriggerEvent('vicecity:appearance:saved', ViceCity.Appearance.Get())
end)

AddEventHandler('17mov_CharacterSystem:OpenOutfitsMenu', function()
    TriggerEvent('vicecity:wardrobe:opened', ViceCity.Appearance.GetProvider())
end)

AddEventHandler('vicecity:appearance:openWardrobe', function(options)
    ViceCity.Wardrobe.Open(options)
end)

AddEventHandler('vicecity:appearance:apply', function(appearance)
    ViceCity.Appearance.Set(PlayerPedId(), appearance)
    TriggerEvent('vicecity:appearance:applied', appearance)
end)
