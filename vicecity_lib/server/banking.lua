--[[
    Banking layer (server) — server-side banking facade with normalized API.
    Routes all calls through the detected provider adapter.
]]

local function adapter()
    return ViceCity.BankingAdapter
end

local function call(name, ...)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.Banking.GetProvider() }
    end
    local ok, first, second = pcall(method, provider, ...)
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(first) }
    end
    return first, second
end

-- Server-side banking operations
ViceCity.Banking = ViceCity.Banking or {}

function ViceCity.Banking.ServerCreateAccount(accountType, name, label, owner)
    return call('createAccount', accountType, name, label, owner)
end

function ViceCity.Banking.ServerEnsureAccount(accountType, name, label, owner)
    return call('ensureAccount', accountType, name, label, owner)
end

function ViceCity.Banking.ServerGetAccount(accountId)
    return call('getAccount', accountId)
end

function ViceCity.Banking.ServerGetAccounts(owner, accountType)
    return call('getAccounts', owner, accountType)
end

function ViceCity.Banking.ServerGetAccountBalance(accountId)
    return call('getAccountBalance', accountId)
end

function ViceCity.Banking.ServerAddMoney(accountId, amount, reason, source)
    return call('addMoney', accountId, amount, reason, source)
end

function ViceCity.Banking.ServerRemoveMoney(accountId, amount, reason, source)
    return call('removeMoney', accountId, amount, reason, source)
end

function ViceCity.Banking.ServerTransferMoney(fromAccountId, toAccountId, amount, reason, source)
    return call('transferMoney', fromAccountId, toAccountId, amount, reason, source)
end

function ViceCity.Banking.ServerDeposit(accountId, amount, reason, source)
    return call('deposit', accountId, amount, reason, source)
end

function ViceCity.Banking.ServerWithdraw(accountId, amount, reason, source)
    return call('withdraw', accountId, amount, reason, source)
end

function ViceCity.Banking.ServerHasAccessToAccount(source, accountId, role)
    return call('hasAccessToAccount', source, accountId, role)
end

function ViceCity.Banking.ServerAddAccountUser(accountId, identifier, role)
    return call('addAccountUser', accountId, identifier, role)
end

function ViceCity.Banking.ServerRemoveAccountUser(accountId, identifier)
    return call('removeAccountUser', accountId, identifier)
end

function ViceCity.Banking.ServerSetAccountRole(accountId, identifier, role)
    return call('setAccountRole', accountId, identifier, role)
end

function ViceCity.Banking.ServerGetAccountUsers(accountId)
    return call('getAccountUsers', accountId)
end

function ViceCity.Banking.ServerGetTransactions(accountId, limit)
    return call('getTransactions', accountId, limit)
end

function ViceCity.Banking.ServerAddTransaction(accountId, sender, receiver, amount, txType, reason, source)
    return call('addTransaction', accountId, sender, receiver, amount, txType, reason, source)
end

function ViceCity.Banking.ServerCreateJobAccount(job, label)
    return call('createJobAccount', job, label)
end

function ViceCity.Banking.ServerCreateGangAccount(gang, label)
    return call('createGangAccount', gang, label)
end

function ViceCity.Banking.ServerCreateBusinessAccount(businessId, label, owner)
    return call('createBusinessAccount', businessId, label, owner)
end

function ViceCity.Banking.ServerDeleteAccount(accountId)
    return call('deleteAccount', accountId)
end

function ViceCity.Banking.ServerGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end

-- Compatibility aliases
CreateAccount = function(type, name, label, owner) return ViceCity.Banking.ServerCreateAccount(type, name, label, owner) end
AddMoney = function(id, amount, reason, source) return ViceCity.Banking.ServerAddMoney(id, amount, reason, source) end
RemoveMoney = function(id, amount, reason, source) return ViceCity.Banking.ServerRemoveMoney(id, amount, reason, source) end
TransferMoney = function(from, to, amount, reason, source) return ViceCity.Banking.ServerTransferMoney(from, to, amount,
        reason, source) end
