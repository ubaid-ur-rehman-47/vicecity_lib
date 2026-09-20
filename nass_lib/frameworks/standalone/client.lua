if GetResourceState('qb-core') == 'started' then return end
if GetResourceState('es_extended') == 'started' then return end
nass.framework = "standalone"

function nass.getPlayerName()
    return GetPlayerName(PlayerId())
end

function nass.notify(msg, type, title, length)
    if GetResourceState('nass_notifications') == 'started' then
        exports["nass_notifications"]:ShowNotification(type or "alert", title or "Info", msg, length or 5000)
    else
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(msg)
        EndTextCommandThefeedPostTicker(0, 1)
    end
end