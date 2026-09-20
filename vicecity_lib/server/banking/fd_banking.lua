--[[
    fd_banking server adapter
]]

ViceCityCreateServerBankingAdapter('fd_banking', 'fd_banking', {
    capabilities = {
        createAccount = true,
        getAccount = true,
        getAccounts = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        hasAccessToAccount = true,
        getTransactions = true,
    },

    createAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'job' then
            return exports['fd_banking']:CreateJobAccount(name, label or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType }
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['fd_banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccounts = function(self, owner, accountType)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local accounts = exports['fd_banking']:GetAllAccounts()
        if not accounts then return {} end
        return accounts
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['fd_banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account.balance or 0
    end,

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        exports['fd_banking']:AddBalance(accountId, amount)
        TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
        return true
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = (exports['fd_banking']:GetAccount(accountId) or {}).balance or 0
        if balance < amount then
            return false, { reason = 'insufficient_funds', accountId = accountId }
        end

        exports['fd_banking']:RemoveBalance(accountId, amount)
        TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
        return true
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['fd_banking']:GetAccount(accountId)
        if not account then return false end
        return true
    end,

    getTransactions = function(self, accountId, limit)
        if not GetResourceState('fd_banking') or GetResourceState('fd_banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local transactions = exports['fd_banking']:GetTransactions(accountId) or {}
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
