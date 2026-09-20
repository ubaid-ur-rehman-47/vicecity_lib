local notifTypeConfig = {
    ['cd_notifications'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['codem-notification'] = {
        [1] = 'check',
        [2] = 'info',
        [3] = 'error',
    },
    ['codem-supreme-notification'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['mythic_notify'] = {
        [1] = 'success',
        [2] = 'inform',
        [3] = 'error',
    },
    ['okokNotify'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['ox_lib'] = {
        [1] = 'success',
        [2] = 'inform',
        [3] = 'error',
    },
    ['pNotify'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['ps-ui'] = {
        [1] = 'success',
        [2] = 'primary',
        [3] = 'error',
    },
    ['qbcore'] = {
        [1] = 'success',
        [2] = 'primary',
        [3] = 'error',
    },
    ['qbox'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['rtx_notify'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['ZSX_UI'] = {
        [1] = 'fas fa-check',
        [2] = 'fas fa-info',
        [3] = 'fas fa-exclamation-triangle',
    },
    ['ZSX_UIV2'] = {
        [1] = 'fas fa-check',
        [2] = 'fas fa-info',
        [3] = 'fas fa-exclamation-triangle',
    },
    ['17mov_Hud'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
    ['other'] = {
        [1] = 'success',
        [2] = 'info',
        [3] = 'error',
    },
}

--- @param source number The players source.
--- @param notif_type '1' | '2' | '3' | number The type of notification (1=success, 2=info, 3=error).
--- @param message string The notifications message.
function Notification(source, notif_type, message)
    if not source or not notif_type or not message then ERROR('7231', 'Notifications arguments error') return end

    local title = Locale('title')
    local newNotifType = notifTypeConfig[Cfg.Notification] and notifTypeConfig[Cfg.Notification][notif_type]

    if Cfg.Notification == 'cd_notifications' then
        TriggerClientEvent('cd_notifications:Add', source, {
            title = Locale('title'),
            message = message,
            type = newNotifType,
        })

    elseif Cfg.Notification == 'chat' then
        TriggerClientEvent('chatMessage', source, message)

    elseif Cfg.Notification == 'codem-notification' then
        TriggerClientEvent('codem-notification', source, message, 5000, newNotifType)

    elseif Cfg.Notification == 'codem-supreme-notification' then
        TriggerClientEvent("codem-notification:send", source, newNotifType, message, 5000)

    elseif Cfg.Notification == 'esx' then
        TriggerClientEvent('esx:showNotification', source, message)

    elseif Cfg.Notification == 'mythic_notify' then
        TriggerClientEvent('mythic_notify:DoLongHudText', source, newNotifType, message)

    elseif Cfg.Notification == 'okokNotify' then
        TriggerClientEvent('okokNotify:Alert', source, title, message, 5000, newNotifType)

    elseif Cfg.Notification == 'origen_notify' then
        exports['origen_notify']:ShowNotification(source, message)

    elseif Cfg.Notification == 'ox_lib' then
        TriggerClientEvent('ox_lib:notify', source, { title = title, description = message, type = newNotifType })

    elseif Cfg.Notification == 'pNotify' then
        TriggerClientEvent('pNotify:SendNotification', source, { text = message, type = newNotifType, timeout = 5000 })

    elseif Cfg.Notification == 'ps-ui' then
        TriggerClientEvent('ps-ui:Notify', source, message, newNotifType)

    elseif Cfg.Notification == 'qbcore' then
        TriggerClientEvent('QBCore:Notify', source, message, newNotifType)

    elseif Cfg.Notification == 'qbox' then
        exports['qbx_core']:Notify(source, message, newNotifType)

    elseif Cfg.Notification == 'rtx_notify' then
        TriggerClientEvent('rtx_notify:Notify', source, title, message, 5000, newNotifType)

    elseif Cfg.Notification == 'vms_notifyv2' then
        TriggerClientEvent('vms_notifyv2:Notification', source, { title = title, description = message, time = 5000, color = '#34ebe8', icon = 'fa-solid fa-check'})

    elseif Cfg.Notification == 'ZSX_UIV2' then
        TriggerClientEvent('ZSX_UI:addNotify', source, newNotifType, title, message, 5000)

    elseif Cfg.Notification == 'ZSX_UIV2' then
        TriggerClientEvent('ZSX_UIV2:addNotify', source, title, message, newNotifType, 5000)

    elseif Cfg.Notification == '17mov_Hud' then
        TriggerClientEvent('17mov_Hud:ShowNotification', source, message, newNotifType, title, 5000)

    elseif Cfg.Notification == 'other' then
        -- Implement other notification method here.
    else
        ERROR('8743', 'Notification system not configured properly in cd_bridge/shared/config.lua')
    end
end