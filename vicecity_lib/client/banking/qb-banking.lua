--[[
    qb-banking client adapter
]]

ViceCityCreateClientBankingAdapter('qb-banking', 'qb-banking', {
    capabilities = {
        openBankingMenu = true,
        getAccounts = true,
        getAccountBalance = true,
        hasAccessToAccount = true,
        getTransactions = true,
    },

    openBankingMenu = function(self, accountId)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        TriggerEvent('qb-banking:openBanking')
        return true
    end,

    getAccounts = function(self)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local accounts = exports['qb-banking']:GetAccounts()
        return accounts or {}, accounts
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local balance = exports['qb-banking']:GetAccountBalance(accountId)
        if not balance then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return balance
    end,

    hasAccessToAccount = function(self, accountId)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local accounts = exports['qb-banking']:GetAccounts()
        if not accounts then return false end
        for _, account in ipairs(accounts) do
            if account.accountId == accountId or account.id == accountId then
                return true
            end
        end
        return false
    end,

    getTransactions = function(self, accountId, limit)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local transactions = exports['qb-banking']:GetTransactions(accountId)
        if not transactions then return {} end

        if limit and limit > 0 then
            local result = {}
            for i = 1, math.min(limit, #transactions) do
                result[i] = transactions[i]
            end
            return result
        end
        return transactions
    end,
})
