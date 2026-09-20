--[[
    okokBanking server adapter — supports job, society, and personal accounts
]]

ViceCityCreateServerBankingAdapter('okokbanking', 'okokbanking', {
    capabilities = {
        createAccount = true,
        ensureAccount = true,
        getAccount = true,
        getAccounts = true,
        getAccountBalance = true,
        addMoney = true,
        removeMoney = true,
        transferMoney = true,
        hasAccessToAccount = true,
        addAccountUser = true,
        removeAccountUser = true,
        setAccountRole = true,
        getAccountUsers = true,
        getTransactions = true,
        addTransaction = true,
        createJobAccount = true,
        createGangAccount = true,
        createBusinessAccount = true,
        deleteAccount = true,
    },

    createAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        if accountType == 'job' then
            return exports.okokbanking:CreateJobAccount(name, label or name)
        elseif accountType == 'gang' then
            return exports.okokbanking:CreateGangAccount(name, label or name)
        elseif accountType == 'business' or accountType == 'business_account' then
            return exports.okokbanking:CreateBusinessAccount(name, owner, label or name)
        elseif accountType == 'personal' then
            return exports.okokbanking:CreateAccount(owner or name)
        end

        return false, { reason = 'unsupported_type', accountType = accountType }
    end,

    ensureAccount = function(self, accountType, name, label, owner)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end

        local account = exports.okokbanking:GetAccount(name)
        if account then
            return account, account
        end

        return self:createAccount(accountType, name, label, owner)
    end,

    getAccount = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account
    end,

    getAccounts = function(self, owner, accountType)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local accounts = exports.okokbanking:GetAllAccounts()
        if not accounts then return {} end

        local result = {}
        for _, account in ipairs(accounts) do
            if accountType then
                if account.type == accountType then
                    table.insert(result, account)
                end
            else
                table.insert(result, account)
            end
        end
        return result
    end,

    getAccountBalance = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account.balance or 0
    end,

    addMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:AddMoney(accountId, amount)
        if success then
            exports.okokbanking:AddTransaction(accountId, 'system', accountId, amount, 'deposit', reason or 'N/A')
            TriggerEvent('vicecity:banking:moneyAdded', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'add_money_failed', accountId = accountId }
    end,

    removeMoney = function(self, accountId, amount, reason, source)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:RemoveMoney(accountId, amount)
        if success then
            exports.okokbanking:AddTransaction(accountId, accountId, 'system', amount, 'withdrawal', reason or 'N/A')
            TriggerEvent('vicecity:banking:moneyRemoved', accountId, amount, reason, source)
            return true
        end
        return false, { reason = 'remove_money_failed', accountId = accountId }
    end,

    transferMoney = function(self, fromAccountId, toAccountId, amount, reason, source)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:TransferMoney(fromAccountId, toAccountId, amount)
        if success then
            exports.okokbanking:AddTransaction(fromAccountId, fromAccountId, toAccountId, amount, 'transfer',
                reason or 'N/A')
            exports.okokbanking:AddTransaction(toAccountId, fromAccountId, toAccountId, amount, 'transfer',
                reason or 'N/A')
            TriggerEvent('vicecity:banking:moneyTransferred', fromAccountId, toAccountId, amount, reason, source)
            return true
        end
        return false, { reason = 'transfer_failed', from = fromAccountId, to = toAccountId }
    end,

    hasAccessToAccount = function(self, source, accountId, role)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account then return false end

        if not account.users then return false end
        local identifier = ViceCity.Framework.GetIdentifier(source)

        for _, user in ipairs(account.users) do
            if user.identifier == identifier then
                if not role then return true end
                return user.role == role or user.role == 'owner'
            end
        end
        return false
    end,

    addAccountUser = function(self, accountId, identifier, role)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:AddAccountUser(accountId, identifier, role or 'member')
        if success then
            TriggerEvent('vicecity:banking:userAdded', accountId, identifier, role)
            return true
        end
        return false, { reason = 'add_user_failed', accountId = accountId }
    end,

    removeAccountUser = function(self, accountId, identifier)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:RemoveAccountUser(accountId, identifier)
        if success then
            TriggerEvent('vicecity:banking:userRemoved', accountId, identifier)
            return true
        end
        return false, { reason = 'remove_user_failed', accountId = accountId }
    end,

    setAccountRole = function(self, accountId, identifier, role)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:SetAccountRole(accountId, identifier, role)
        if success then
            TriggerEvent('vicecity:banking:roleChanged', accountId, identifier, role)
            return true
        end
        return false, { reason = 'set_role_failed', accountId = accountId }
    end,

    getAccountUsers = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account or not account.users then
            return {}
        end
        return account.users
    end,

    getTransactions = function(self, accountId, limit)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local transactions = exports.okokbanking:GetTransactions(accountId)
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

    addTransaction = function(self, accountId, sender, receiver, amount, txType, reason, source)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:AddTransaction(accountId, sender, receiver, amount, txType, reason)
        if success then
            TriggerEvent('vicecity:banking:transactionAdded', accountId, sender, receiver, amount, txType)
            return true
        end
        return false, { reason = 'add_transaction_failed', accountId = accountId }
    end,

    createJobAccount = function(self, job, label)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        return self:createAccount('job', job, label or job)
    end,

    createGangAccount = function(self, gang, label)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        return self:createAccount('gang', gang, label or gang)
    end,

    createBusinessAccount = function(self, businessId, label, owner)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        return self:createAccount('business', businessId, label or businessId, owner)
    end,

    deleteAccount = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local success = exports.okokbanking:DeleteAccount(accountId)
        if success then
            TriggerEvent('vicecity:banking:accountDeleted', accountId)
            return true
        end
        return false, { reason = 'delete_account_failed', accountId = accountId }
    end,
})
