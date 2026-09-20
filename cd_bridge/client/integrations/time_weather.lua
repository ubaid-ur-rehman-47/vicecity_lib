function PauseTimeWeatherSyncWhenEnteringShell()
    if Config.TimeWeather == 'cd_easytime' then
        TriggerEvent('cd_easytime:PauseSync', true)

    elseif Config.TimeWeather == 'qb-weathersync' then
        TriggerEvent('qb-weathersync:client:DisableSync')

    elseif Config.TimeWeather == 'vsync' then
        TriggerEvent('vSync:toggle',false)
        NetworkOverrideClockTime(20, 00, 00)

    elseif Config.TimeWeather == 'codem-dynamicweather' then
        exports['codem-dynamicweather'].setLocalWeather('EXTRASUNNY', 30)
    end
end

function ResumeTimeWeatherSyncWhenEnteringShell()
    if Config.TimeWeather == 'cd_easytime' then
        TriggerEvent('cd_easytime:PauseSync', false)

    elseif Config.TimeWeather == 'qb-weathersync' then
        TriggerEvent('qb-weathersync:client:EnableSync')

    elseif Config.TimeWeather == 'vsync' then
        TriggerEvent('vSync:toggle',true)
        TriggerServerEvent('vSync:requestSync')

    elseif Config.TimeWeather == 'codem-dynamicweather' then
        exports['codem-dynamicweather'].clearLocalWeather()
    end
end