--[[
    qb-banking server adapter
]]

ViceCityCreateServerBankingAdapter('qb-banking', 'qb-banking', {
    capabilities = {
        createAccount = true,
        getAccount = true,
        getAccounts = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        transferMoney = true,
        hasAccessToAccount = true,
        getTransactions = true,
    },

    createAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'job' then
            return exports['qb-banking']:CreateJobAccount(name, label or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType, provider = self.name }
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports['qb-banking']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccounts = function(self, owner, accountType)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local accounts = exports['qb-banking']:GetAccounts()
        if not accounts then return {} end
        return accounts
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

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports['qb-banking']:AddMoney(accountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'add_money_failed', accountId = accountId }
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports['qb-banking']:RemoveMoney(accountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'remove_money_failed', accountId = accountId }
    end,

    transferMoney = function(self, fromAccountId, toAccountId, amount, reason, source)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports['qb-banking']:TransferMoney(fromAccountId, toAccountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyTransferred', fromAccountId, toAccountId, amount, reason, source)
            return true
        end
        return false, { reason = 'transfer_failed', from = fromAccountId, to = toAccountId }
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('qb-banking') or GetResourceState('qb-banking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports['qb-banking']:GetAccount(accountId)
        if not account then return false end
        return true
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
