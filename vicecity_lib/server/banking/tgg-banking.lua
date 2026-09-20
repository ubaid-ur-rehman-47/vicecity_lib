--[[
    tgg-banking server adapter
]]

ViceCityCreateServerBankingAdapter('tgg-banking', 'tgg-banking', {
    capabilities = {
        createAccount = true,
        getAccount = true,
        getAccounts = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        transferMoney = true,
        hasAccessToAccount = true,
    },

    createAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'job' then
            return exports['tgg-banking']:CreateJobAccount(name, label or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType }
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['tgg-banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccounts = function(self, owner, accountType)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local accounts = exports['tgg-banking']:GetAllAccounts()
        if not accounts then return {} end
        return accounts
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports['tgg-banking']:GetBalance(accountId)
        if balance == nil then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return balance or 0
    end,

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        exports['tgg-banking']:AddBalance(accountId, amount)
        TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
        return true
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports['tgg-banking']:GetBalance(accountId) or 0
        if balance < amount then
            return false, { reason = 'insufficient_funds', accountId = accountId }
        end

        exports['tgg-banking']:RemoveBalance(accountId, amount)
        TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
        return true
    end,

    transferMoney = function(self, fromAccountId, toAccountId, amount, reason, source)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local fromBalance = exports['tgg-banking']:GetBalance(fromAccountId) or 0
        if fromBalance < amount then
            return false, { reason = 'insufficient_funds', from = fromAccountId }
        end

        exports['tgg-banking']:RemoveBalance(fromAccountId, amount)
        exports['tgg-banking']:AddBalance(toAccountId, amount)
        TriggerEvent('vicecity:banking:moneyTransferred', fromAccountId, toAccountId, amount, reason, source)
        return true
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('tgg-banking') or GetResourceState('tgg-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['tgg-banking']:GetAccount(accountId)
        if not account then return false end
        return true
    end,
})
