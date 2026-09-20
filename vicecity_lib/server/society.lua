--[[
    Society layer (server) — server-side society/job fund facade.
    Wraps banking operations for society, job, and gang accounts.
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

ViceCity.Society = ViceCity.Society or {}

function ViceCity.Society.Ensure(societyName, label, societyType)
    societyType = societyType or 'job'
    if societyType == 'job' then
        return call('createJobAccount', societyName, label or societyName)
    elseif societyType == 'gang' then
        return call('createGangAccount', societyName, label or societyName)
    end
    return false, { reason = 'invalid_type', societyType = societyType }
end

function ViceCity.Society.Create(societyName, label, societyType)
    return ViceCity.Society.Ensure(societyName, label, societyType)
end

function ViceCity.Society.Delete(societyName)
    return call('deleteAccount', societyName)
end

function ViceCity.Society.Get(societyName)
    return call('getAccount', societyName)
end

function ViceCity.Society.Balance(societyName)
    local ok, balance = call('getAccountBalance', societyName)
    return ok and balance or 0
end

function ViceCity.Society.AddMoney(societyName, amount, reason, source)
    if not societyName or type(amount) ~= 'number' or amount <= 0 then return false end
    return (select(1, call('addMoney', societyName, math.floor(amount + 0.5), reason, source))) == true
end

function ViceCity.Society.RemoveMoney(societyName, amount, reason, source)
    if not societyName or type(amount) ~= 'number' or amount <= 0 then return false end
    return (select(1, call('removeMoney', societyName, math.floor(amount + 0.5), reason, source))) == true
end

function ViceCity.Society.TransferMoney(fromSociety, toSociety, amount, reason, source)
    if not fromSociety or not toSociety or type(amount) ~= 'number' or amount <= 0 then return false end
    return (select(1, call('transferMoney', fromSociety, toSociety, math.floor(amount + 0.5), reason, source))) == true
end

function ViceCity.Society.HasAccess(source, societyName, role)
    return call('hasAccessToAccount', source, societyName, role)
end

function ViceCity.Society.AddMember(societyName, identifier, role)
    return call('addAccountUser', societyName, identifier, role or 'member')
end

function ViceCity.Society.RemoveMember(societyName, identifier)
    return call('removeAccountUser', societyName, identifier)
end

function ViceCity.Society.SetMemberRole(societyName, identifier, role)
    return call('setAccountRole', societyName, identifier, role)
end

function ViceCity.Society.GetMembers(societyName)
    return call('getAccountUsers', societyName)
end

function ViceCity.Society.GetTransactions(societyName, limit)
    return call('getTransactions', societyName, limit)
end

-- Compatibility aliases
SocietyPay = function(name, amount, reason, source) return ViceCity.Society.AddMoney(name, amount, reason, source) end
SocietyRemove = function(name, amount, reason, source) return ViceCity.Society.RemoveMoney(name, amount, reason, source) end
SocietyBalance = function(name) return ViceCity.Society.Balance(name) end
