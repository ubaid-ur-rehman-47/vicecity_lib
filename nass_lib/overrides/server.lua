Wait(1000)
if GetResourceState('nass_bossmenu') ~= "missing" then
    function nass.addSocietyMoney(society, amount)
        if string.match(society, "society_") then
            society = society:gsub("^society_", "")
        end

        return exports["nass_bossmenu"]:addMoney(society, amount)
    end

    function nass.removeSocietyMoney(society, amount)
        if string.match(society, "society_") then
            society = society:gsub("^society_", "")
        end

        if amount > 0 and exports["nass_bossmenu"]:getAccount(society) >= amount then
            exports["nass_bossmenu"]:removeMoney(society, amount)
            return true
        else
            return false
        end
    end

    function nass.getSocietyMoney(society)
        if string.match(society, "society_") then
            society = society:gsub("^society_", "")
        end
        
        return exports["nass_bossmenu"]:getAccount(society) or 0
    end
end