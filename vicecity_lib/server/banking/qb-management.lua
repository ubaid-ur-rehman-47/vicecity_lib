--[[
    QB-Management Framework banking adapter — QB jobs/gangs society accounts
]]

ViceCityCreateServerBankingAdapter('qb-management', 'qb-management', {
    capabilities = {
        createAccount = true,
        getAccount = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        transferMoney = true,
        hasAccessToAccount = true,
        getAccountUsers = true,
        createJobAccount = true,
        createGangAccount = true,
    },

    createAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'job' then
            return self:createJobAccount(name, label or name)
        elseif accountType == 'gang' then
            return self:createGangAccount(name, label or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType }
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qb-management']:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports['qb-management']:GetAccountBalance(accountId)
        if balance == nil then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return balance or 0
    end,

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local success = exports['qb-management']:AddMoney(accountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'add_money_failed', accountId = accountId }
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local balance = exports['qb-management']:GetAccountBalance(accountId)
        if not balance or balance < amount then
            return false, { reason = 'insufficient_funds', accountId = accountId }
        end

        local success = exports['qb-management']:RemoveMoney(accountId, amount)
        if success then
            TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'remove_money_failed', accountId = accountId }
    end,

    transferMoney = function(self, fromAccountId, toAccountId, amount, reason, source)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local fromBalance = exports['qb-management']:GetAccountBalance(fromAccountId)
        if not fromBalance or fromBalance < amount then
            return false, { reason = 'insufficient_funds', from = fromAccountId }
        end

        exports['qb-management']:RemoveMoney(fromAccountId, amount)
        exports['qb-management']:AddMoney(toAccountId, amount)
        TriggerEvent('vicecity:banking:moneyTransferred', fromAccountId, toAccountId, amount, reason, source)
        return true
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qb-management']:GetAccount(accountId)
        if not account then return false end
        return true
    end,

    getAccountUsers = function(self, accountId)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports['qb-management']:GetAccount(accountId)
        if not account or not account.members then return {} end
        return account.members
    end,

    createJobAccount = function(self, job, label)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        return exports['qb-management']:CreateJobAccount(job, label or job)
    end,

    createGangAccount = function(self, gang, label)
        if not GetResourceState('qb-management') or GetResourceState('qb-management') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        return exports['qb-management']:CreateGangAccount(gang, label or gang)
    end,
})
