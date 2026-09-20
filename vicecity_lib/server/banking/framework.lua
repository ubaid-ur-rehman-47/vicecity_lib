--[[
    Framework fallback banking adapter — uses underlying ESX/QB framework
]]

ViceCityCreateServerBankingAdapter('framework', nil, {
    capabilities = {
        createJobAccount = true,
        createGangAccount = true,
        getAccount = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        hasAccessToAccount = true,
    },

    createJobAccount = function(self, job, label)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' then
            if GetResourceState('esx_society') == 'started' then
                return exports.esx_society:CreateSociety(job, label or job, 'job')
            end
        elseif fw.name == 'QBCore' then
            if GetResourceState('qb-management') == 'started' then
                return exports['qb-management']:CreateJobAccount(job, label or job)
            end
        end

        return false, { reason = 'unsupported_framework', framework = fw.name }
    end,

    createGangAccount = function(self, gang, label)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' then
            if GetResourceState('esx_society') == 'started' then
                return exports.esx_society:CreateSociety(gang, label or gang, 'gang')
            end
        elseif fw.name == 'QBCore' then
            if GetResourceState('qb-management') == 'started' then
                return exports['qb-management']:CreateGangAccount(gang, label or gang)
            end
        end

        return false, { reason = 'unsupported_framework', framework = fw.name }
    end,

    getAccount = function(self, accountId)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' and GetResourceState('esx_society') == 'started' then
            return exports.esx_society:GetSociety(accountId)
        elseif fw.name == 'QBCore' and GetResourceState('qb-management') == 'started' then
            return exports['qb-management']:GetAccount(accountId)
        end

        return false, { reason = 'account_not_found', accountId = accountId }
    end,

    getAccountBalance = function(self, accountId)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' and GetResourceState('esx_society') == 'started' then
            return exports.esx_society:GetSocietyMoney(accountId) or 0
        elseif fw.name == 'QBCore' and GetResourceState('qb-management') == 'started' then
            return exports['qb-management']:GetAccountBalance(accountId) or 0
        end

        return false, { reason = 'account_not_found', accountId = accountId }
    end,

    addMoney = function(self, accountId, amount, reason, source)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' and GetResourceState('esx_society') == 'started' then
            exports.esx_society:AddSocietyMoney(accountId, amount)
            TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
            return true
        elseif fw.name == 'QBCore' and GetResourceState('qb-management') == 'started' then
            exports['qb-management']:AddMoney(accountId, amount)
            TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
            return true
        end

        return false, { reason = 'unsupported_framework', framework = fw.name }
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' and GetResourceState('esx_society') == 'started' then
            local balance = exports.esx_society:GetSocietyMoney(accountId) or 0
            if balance < amount then
                return false, { reason = 'insufficient_funds', accountId = accountId }
            end
            exports.esx_society:RemoveSocietyMoney(accountId, amount)
            TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
            return true
        elseif fw.name == 'QBCore' and GetResourceState('qb-management') == 'started' then
            local balance = exports['qb-management']:GetAccountBalance(accountId) or 0
            if balance < amount then
                return false, { reason = 'insufficient_funds', accountId = accountId }
            end
            exports['qb-management']:RemoveMoney(accountId, amount)
            TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
            return true
        end

        return false, { reason = 'unsupported_framework', framework = fw.name }
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        local fw = ViceCity.Framework.GetFramework()
        if not fw then
            return false, { reason = 'framework_not_loaded', provider = self.name }
        end

        if fw.name == 'ESX' and GetResourceState('esx_society') == 'started' then
            local account = exports.esx_society:GetSociety(accountId)
            return account ~= nil
        elseif fw.name == 'QBCore' and GetResourceState('qb-management') == 'started' then
            local account = exports['qb-management']:GetAccount(accountId)
            return account ~= nil
        end

        return false
    end,
})
