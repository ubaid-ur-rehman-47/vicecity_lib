--[[
    Banking and society layer (shared) — defines account model, contract,
    capability flags, and normalized operations across all banking providers.

    Global API:
      ViceCity.Banking.*         client/server banking operations
      ViceCity.Society.*         society/job fund operations
      ViceCity.BankingAdapter    registration point for custom providers
]]

ViceCity.Banking = ViceCity.Banking or {}
ViceCity.Society = ViceCity.Society or {}

-- Account types
local ACCOUNT_TYPES = {
    personal = 'personal',
    society = 'society',
    job = 'job',
    gang = 'gang',
    business = 'business',
    shared = 'shared',
}

-- Account roles and permissions
local ACCOUNT_ROLES = {
    owner = 'owner',
    manager = 'manager',
    employee = 'employee',
    member = 'member',
    viewer = 'viewer',
}

-- Transaction types
local TRANSACTION_TYPES = {
    deposit = 'deposit',
    withdrawal = 'withdrawal',
    transfer = 'transfer',
    payment = 'payment',
    bill = 'bill',
    salary = 'salary',
    refund = 'refund',
    society_deposit = 'society_deposit',
    society_withdrawal = 'society_withdrawal',
    loan_payment = 'loan_payment',
    savings_deposit = 'savings_deposit',
    interest = 'interest',
}

-- Normalized account structure
local function createAccount(id, accountType, name, label, owner, balance)
    return {
        id = id,
        type = accountType,
        name = name,
        label = label or name,
        owner = owner,
        balance = balance or 0,
        currency = 'USD',
        iban = nil,
        permissions = {},
        metadata = {},
        raw = nil,
    }
end

-- Normalized transaction structure
local function createTransaction(id, accountId, sender, receiver, amount, txType, reason, timestamp)
    return {
        id = id,
        accountId = accountId,
        sender = sender,
        receiver = receiver,
        amount = amount,
        type = txType,
        reason = reason,
        timestamp = timestamp or os.time(),
        balanceAfter = 0,
        raw = nil,
    }
end

-- Result wrapper for unsupported/error cases
local function unsupportedResult(operation, provider, reason)
    return {
        ok = false,
        reason = reason or 'unsupported',
        operation = operation,
        provider = provider,
    }
end

local function forbiddenResult(operation, reason)
    return {
        ok = false,
        reason = reason or 'forbidden',
        operation = operation,
    }
end

local function errorResult(operation, reason, provider)
    return {
        ok = false,
        reason = reason or 'error',
        operation = operation,
        provider = provider,
    }
end

-- Export constants
ViceCity.BankingAccountTypes = ACCOUNT_TYPES
ViceCity.BankingAccountRoles = ACCOUNT_ROLES
ViceCity.BankingTransactionTypes = TRANSACTION_TYPES
ViceCity.BankingCreateAccount = createAccount
ViceCity.BankingCreateTransaction = createTransaction
ViceCity.BankingUnsupportedResult = unsupportedResult
ViceCity.BankingForbiddenResult = forbiddenResult
ViceCity.BankingErrorResult = errorResult

-- Banking namespace
ViceCity.Banking = ViceCity.Banking or {}

-- Get the active banking provider
function ViceCity.Banking.GetProvider()
    return ViceCity.GetProvider('banking') or 'none'
end

-- Get capabilities of the active banking provider
function ViceCity.Banking.GetCapabilities()
    local provider = ViceCity.BankingAdapter
    return provider and provider.capabilities or {}
end

