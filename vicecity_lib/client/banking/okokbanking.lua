--[[
    okokBanking client adapter
]]

ViceCityCreateClientBankingAdapter('okokbanking', 'okokbanking', {
    capabilities = {
        openBankingMenu = true,
        getAccounts = true,
        getAccountBalance = true,
        hasAccessToAccount = true,
        getTransactions = true,
        getCards = true,
        getAccountIBAN = true,
        getAccountPIN = true,
        setAccountPIN = true,
        getCreditScore = true,
        getLoans = true,
        getSavingGoals = true,
        openLoanMenu = true,
    },

    openBankingMenu = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        if accountId then
            return TriggerEvent('okokbanking:open', accountId) or true
        else
            return TriggerEvent('okokbanking:open') or true
        end
    end,

    getAccounts = function(self)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local accounts = exports.okokbanking:GetAllAccounts()
        return accounts or {}, accounts
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

    hasAccessToAccount = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account then return false end
        return true
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

    getCards = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account or not account.cards then return {} end
        return account.cards
    end,

    getAccountIBAN = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account.iban or nil
    end,

    getAccountPIN = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account then
            return false, { reason = 'account_not_found', accountId = accountId }
        end
        return account.pin or nil
    end,

    setAccountPIN = function(self, accountId, pin)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        return TriggerServerEvent('okokbanking:setPIN', accountId, pin) or true
    end,

    getCreditScore = function(self)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local score = exports.okokbanking:GetCreditScore()
        return score or 500
    end,

    getLoans = function(self)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local loans = exports.okokbanking:GetLoans()
        return loans or {}
    end,

    getSavingGoals = function(self, accountId)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        local account = exports.okokbanking:GetAccount(accountId)
        if not account or not account.savinggoals then return {} end
        return account.savinggoals
    end,

    openLoanMenu = function(self)
        if not GetResourceState('okokbanking') or GetResourceState('okokbanking') ~= 'started' then
            return false, { reason = 'resource_not_started', provider = self.name }
        end
        return TriggerEvent('okokbanking:openLoans') or true
    end,
})
