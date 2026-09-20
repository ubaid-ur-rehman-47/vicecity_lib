RegisterNetEvent('nass_lib:notify')
AddEventHandler('nass_lib:notify', function(...)
    nass.notify(...)
end)

function nass.showHelpNotification(msg)
    AddTextEntry("nass_helpNotif", msg)
    BeginTextCommandDisplayHelp("nass_helpNotif")
    EndTextCommandDisplayHelp(false, false, true, -1)
end