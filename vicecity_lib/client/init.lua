ViceCity.RegisterProvider('framework', 'standalone', {
    name = 'standalone',
    context = 'client',
})

ViceCity.RegisterProvider('database', 'none', {
    name = 'none',
    context = 'client',
})

CreateThread(function()
    ViceCity.Start()
end)
