--[[
    Renewed-Banking server adapter
]]

ViceCityCreateServerBankingAdapter('renewed', 'renewed-banking', {
    capabilities = {
        createAccount = true,
        getAccount = true,
        getAccounts = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        transferMoney = true,
        hasAccessToAccount = true,
        createJobAccount = true,
    },

    createAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'personal' then
            return exports['renewed-banking']:CreateAccount(owner or name, label or name)
        elseif accountType == 'job' then
            return exports['renewed-banking']:CreateJobAccount(name, label or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType }
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['renewed-banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccounts = function(self, owner, accountType)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local accounts = exports['renewed-banking']:GetAccounts(owner)
        if not accounts then return {} end
        return accounts
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports['renewed-banking']:GetBalance(accountId)
        if balance == nil then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return balance or 0
    end,

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local success = exports['renewed-banking']:AddBalance(accountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'add_money_failed', accountId = accountId }
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports['renewed-banking']:GetBalance(accountId) or 0
        if balance < amount then
            return false, { reason = 'insufficient_funds', accountId = accountId }
        end

        local success = exports['renewed-banking']:RemoveBalance(accountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'remove_money_failed', accountId = accountId }
    end,

    transferMoney = function(self, fromAccountId, toAccountId, amount, reason, source)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local fromBalance = exports['renewed-banking']:GetBalance(fromAccountId) or 0
        if fromBalance < amount then
            return false, { reason = 'insufficient_funds', from = fromAccountId }
        end

        exports['renewed-banking']:RemoveBalance(fromAccountId, amount)
        exports['renewed-banking']:AddBalance(toAccountId, amount)
        TriggerEvent('vicecity:banking:moneyTransferred', fromAccountId, toAccountId, amount, reason, source)
        return true
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['renewed-banking']:GetAccount(accountId)
        if not account then return false end
        return true
    end,

    createJobAccount = function(self, job, label)
        if not GetResourceState('renewed-banking') or GetResourceState('renewed-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        return exports['renewed-banking']:CreateJobAccount(job, label or job)
    end,
})
