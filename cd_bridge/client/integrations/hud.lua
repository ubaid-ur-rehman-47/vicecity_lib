local hudVisibility = true

--- @param state boolean -- true to show, false to hide. 
function SetHudVisibility(state)
    hudVisibility = state
    DisplayHud(state)
    DisplayRadar(state)
    TriggerEvent('cd_bridge:HudVisibilityChanged', state)

    if GetResourceState('cd_playerhud') == 'started' then
        local s = state and 'open' or 'close'
        TriggerEvent('cd_playerhud:OpenWatchUI', s)
    end
    if GetResourceState('cd_dispatch3d') == 'started' then
        if state then
            TriggerEvent('cd_dispatch:KEY_smallui_show')
        else
            TriggerEvent('cd_dispatch:KEY_smallui_hide')
        end
    end
    if GetResourceState('cd_radar') == 'started' then
        if state then
            TriggerEvent('cd_radar:ShowRadar')
        else
            TriggerEvent('cd_radar:HideRadar')
        end
    end

    if Cfg.Hud == 'none' then return end

    if Cfg.Hud == 'Codem-BlackHUDV2' then
        TriggerEvent('codem-blackhudv2:SetForceHide', not state, not state)

    elseif Cfg.Hud == 'esx_hud' then
        TriggerEvent('esx_hud:HudToggle', state)

    elseif Cfg.Hud == 'izzy-hudv5' then
        exports['izzy-hudv5']:setDisplay(state)

    elseif Cfg.Hud == 'izzy-hudv6' then
        exports['izzy-hudv6']:setDisplay(state)

    elseif Cfg.Hud == 'izzy-hudv7' then
        if state then
            TriggerEvent('izzy-hud:client:showHUD')
        else
            TriggerEvent('izzy-hud:client:hideHUD')
        end

    elseif Cfg.hud == 'jg-hud' then
        exports['jg-hud']:toggleHud(state)

    elseif Cfg.Hud == 'mHud' then
        if state then
            TriggerEvent('mHud:ShowHud')
        else
            TriggerEvent('mHud:HideHud')
        end

    elseif Cfg.Hud == 'tgiann-lumihud' then
        TriggerEvent('tgiann-lumihud:ui', state)

    elseif Cfg.Hud == 'vms_hud' then
        exports['vms_hud']:Display(state)

    elseif Cfg.Hud == 'wais-hudv6' then
        if state then
            TriggerEvent('wais:hudv6:client:hideHud', false)
            TriggerEvent('wais:hudv6:client:hideRadar', false)
        else
            TriggerEvent('wais:hudv6:client:hideHud', true)
            TriggerEvent('wais:hudv6:client:hideRadar', true)
        end

    elseif Cfg.Hud == '0r-hud-v3' then
        exports['0r-hud-v3']:ToggleVisible(state)

    elseif Cfg.Hud == '17mov_Hud' then
        TriggerEvent('17mov_Hud:ToggleDisplay', state)

    elseif Cfg.Hud == 'other' then
        -- Hide your hud here.
    end
end

--- @return boolean # true if hud is visible, false if hidden.
function GetHudVisibility()
    return hudVisibility
end

RegisterNetEvent('cd_bridge:SetHudVisibility', function(state)
    SetHudVisibility(state)
end)