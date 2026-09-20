--[[
    Banking layer (client) — client-side banking facade with normalized API.
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

-- Client-side banking operations
ViceCity.Banking = ViceCity.Banking or {}

function ViceCity.Banking.ClientOpenBankingMenu(accountId)
    return call('openBankingMenu', accountId)
end

function ViceCity.Banking.ClientOpenATM()
    return call('openATM')
end

function ViceCity.Banking.ClientOpenAccount(accountId)
    return call('openAccount', accountId)
end

function ViceCity.Banking.ClientGetAccounts()
    return call('getAccounts')
end

function ViceCity.Banking.ClientGetActiveAccount()
    return call('getActiveAccount')
end

function ViceCity.Banking.ClientGetAccountBalance(accountId)
    return call('getAccountBalance', accountId)
end

function ViceCity.Banking.ClientHasAccessToAccount(accountId)
    return call('hasAccessToAccount', accountId)
end

function ViceCity.Banking.ClientGetTransactions(accountId, limit)
    return call('getTransactions', accountId, limit)
end

function ViceCity.Banking.ClientGetCards(accountId)
    return call('getCards', accountId)
end

function ViceCity.Banking.ClientGetAccountIBAN(accountId)
    return call('getAccountIBAN', accountId)
end

function ViceCity.Banking.ClientGetAccountPIN(accountId)
    return call('getAccountPIN', accountId)
end

function ViceCity.Banking.ClientSetAccountPIN(accountId, pin)
    return call('setAccountPIN', accountId, pin)
end

function ViceCity.Banking.ClientGetCreditScore()
    return call('getCreditScore')
end

function ViceCity.Banking.ClientGetLoans()
    return call('getLoans')
end

function ViceCity.Banking.ClientGetSavingGoals(accountId)
    return call('getSavingGoals', accountId)
end

function ViceCity.Banking.ClientOpenLoanMenu()
    return call('openLoanMenu')
end

function ViceCity.Banking.ClientOpenSavingsMenu(accountId)
    return call('openSavingsMenu', accountId)
end

function ViceCity.Banking.ClientGetRawProvider()
    local provider = adapter()
    return provider and provider.getRaw and provider:getRaw() or nil
end

-- Compatibility aliases
OpenBankingMenu = function(accountId) return ViceCity.Banking.ClientOpenBankingMenu(accountId) end
GetAccountBalance = function(accountId) return ViceCity.Banking.ClientGetAccountBalance(accountId) end
HasAccessToAccount = function(accountId) return ViceCity.Banking.ClientHasAccessToAccount(accountId) end
