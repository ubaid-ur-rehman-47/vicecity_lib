--[[
    ESX Framework banking adapter (esx_society) — legacy framework-level society accounts
]]

ViceCityCreateServerBankingAdapter('esx_society', 'esx_society', {
    capabilities = {
        createAccount = false,
        getAccount = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        hasAccessToAccount = true,
        getAccountUsers = true,
    },

    getAccount = function(self, societyName)
        if not GetResourceState('esx_society') or GetResourceState('esx_society') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports.esx_society:GetSociety(societyName)
        if not account then
            return false, { reason = 'account_not_found', accountId = societyName }
        end
        return account
    end,

    getAccountBalance = function(self, societyName)
        if not GetResourceState('esx_society') or GetResourceState('esx_society') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports.esx_society:GetSocietyMoney(societyName)
        if not balance then
            return false, { reason = 'account_not_found', accountId = societyName }
        end
        return balance or 0
    end,

    addMoney = function(self, societyName, amount, reason, source)
        if not GetResourceState('esx_society') or GetResourceState('esx_society') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        exports.esx_society:AddSocietyMoney(societyName, amount)
        TriggerEvent('vicecity:banking:moneyAdded', societyName, amount, reason, source)
        return true
    end,

    removeMoney = function(self, societyName, amount, reason, source)
        if not GetResourceState('esx_society') or GetResourceState('esx_society') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports.esx_society:GetSocietyMoney(societyName)
        if not balance or balance < amount then
            return false, { reason = 'insufficient_funds', accountId = societyName }
        end

        exports.esx_society:RemoveSocietyMoney(societyName, amount)
        TriggerEvent('vicecity:banking:moneyRemoved', societyName, amount, reason, source)
        return true
    end,

    hasAccessToAccount = function(self, source, societyName, role)
        if not GetResourceState('esx_society') or GetResourceState('esx_society') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports.esx_society:GetSociety(societyName)
        if not account then return false end
        return true
    end,

    getAccountUsers = function(self, societyName)
        if not GetResourceState('esx_society') or GetResourceState('esx_society') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports.esx_society:GetSociety(societyName)
        if not account or not account.members then return {} end
        return account.members
    end,
})
