--[[
    qs-banking server adapter
]]

ViceCityCreateServerBankingAdapter('qs-banking', 'qs-banking', {
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
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'job' then
            return exports['qs-banking']:CreateJobAccount(name, label or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType }
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qs-banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccounts = function(self, owner, accountType)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local accounts = exports['qs-banking']:GetAllAccounts()
        if not accounts then return {} end
        return accounts
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qs-banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account.balance or 0
    end,

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        exports['qs-banking']:AddBalance(accountId, amount)
        TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
        return true
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qs-banking']:GetAccount(accountId)
        if not account or (account.balance or 0) < amount then
            return false, { reason = 'insufficient_funds', accountId = accountId }
        end

        exports['qs-banking']:RemoveBalance(accountId, amount)
        TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
        return true
    end,

    transferMoney = function(self, fromAccountId, toAccountId, amount, reason, source)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local fromAccount = exports['qs-banking']:GetAccount(fromAccountId)
        if not fromAccount or (fromAccount.balance or 0) < amount then
            return false, { reason = 'insufficient_funds', from = fromAccountId }
        end

        exports['qs-banking']:RemoveBalance(fromAccountId, amount)
        exports['qs-banking']:AddBalance(toAccountId, amount)
        TriggerEvent('vicecity:banking:moneyTransferred', fromAccountId, toAccountId, amount, reason, source)
        return true
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('qs-banking') or GetResourceState('qs-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qs-banking']:GetAccount(accountId)
        if not account then return false end
        return true
    end,
})
