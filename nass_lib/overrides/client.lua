Wait(1000)

if GetResourceState('nass_bossmenu') ~= "missing" then
    function nass.openBossmenu()
        TriggerEvent("nass_bossmenu:openBossMenu")
    end
end

