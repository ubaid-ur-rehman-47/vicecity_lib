ViceCity.RegisterProvider('framework', 'standalone', {
    name = 'standalone',
    context = 'server',
})

ViceCity.RegisterProvider('inventory', 'native', {
    name = 'native',
    context = 'server',
})

ViceCity.RegisterProvider('database', 'none', {
    name = 'none',
    context = 'server',
})

CreateThread(function()
    ViceCity.Start()
end)
