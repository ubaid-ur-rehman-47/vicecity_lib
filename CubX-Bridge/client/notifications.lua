--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

function Notify(message, type, length)
    if not message then return end
    type = type or "info"
    length = length or Config.Notifications.defaultDuration
    
    local typeMap = {
        success = "success",
        error = "error",
        warning = "warning",
        warn = "warning",
        info = "inform",
        inform = "inform",
        primary = "inform",
        default = "inform"
    }
    
    local notifyType = typeMap[type] or "inform"
    
    if CBUX.HasOxLib then
        if Config.Notifications.useOxLib then
            lib.notify({
                title = "Notification",
                description = message,
                type = notifyType,
                duration = length
            })
            return
        end
    end
    
    if CBUX.Framework == "esx" then
        if CBUX.FrameworkObject then
            CBUX.FrameworkObject.ShowNotification(message)
        end
    elseif CBUX.Framework == "qbcore" then
        if CBUX.FrameworkObject then
            CBUX.FrameworkObject.Functions.Notify(message, type, length)
        end
    elseif CBUX.Framework == "qbox" then
        TriggerEvent("QBCore:Notify", message, type, length)
    else
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end

function NotifyAdvanced(options)
    if not options then return end
    if not options.message then return end
    
    local title = options.title or "Notification"
    local message = options.message
    local type = options.type or "info"
    local duration = options.duration or Config.Notifications.defaultDuration
    
    if CBUX.HasOxLib and Config.Notifications.useOxLib then
        lib.notify({
            title = title,
            description = message,
            type = type,
            duration = duration,
            icon = options.icon,
            iconColor = options.iconColor
        })
        return
    end
    
    Notify(title .. ": " .. message, type, duration)
end

function ShowHelpNotification(message, beep, sound, duration)
    if CBUX.HasOxLib then
        lib.showTextUI(message)
        if duration then
            SetTimeout(duration, function()
                lib.hideTextUI()
            end)
        end
        return
    end
    
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, sound or false, duration or -1)
end

function ShowFloatingHelpText(message, coords)
    SetFloatingHelpTextWorldPosition(1, coords.x, coords.y, coords.z)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(2, false, false, -1)
end

exports("Notify", Notify)
exports("NotifyAdvanced", NotifyAdvanced)
exports("ShowHelpNotification", ShowHelpNotification)
exports("ShowFloatingHelpText", ShowFloatingHelpText)
exports("ShowNotification", Notify)
exports("SendNotification", Notify)