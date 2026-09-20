--[[
    Banking layer initialization (server) — loads all banking provider adapters
]]

-- Ensure ViceCity exists
assert(ViceCity, 'ViceCity core not loaded')

-- Initialize banking adapter registry
ViceCity.BankingAdapter = nil

-- Load all provider adapters
local adapterFiles = {
    'okokbanking',
    'qb-banking',
    'renewed',
    'fd_banking',
    'tgg-banking',
    'qs-banking',
    'wasabi',
    'esx_society',
    'qb-management',
    'framework',
}

for _, adapterName in ipairs(adapterFiles) do
    local path = ('server/banking/%s.lua'):format(adapterName)
    local resource = GetCurrentResourceName()

    if GetResourceState(resource) == 'started' then
        local src = LoadResourceFile(resource, path)
        if src then
            local chunk = load(src, ('@%s'):format(path))
            if chunk then
                local ok, err = pcall(chunk)
                if not ok then
                    print(('Warning: Failed to load banking adapter %s: %s'):format(adapterName, err))
                end
            end
        end
    end
end

-- Select the active banking adapter based on configuration
local function selectBankingProvider()
    local config = ViceCityConfig.banking or {}
    local priorityList = config.priority or {}

    for _, providerName in ipairs(priorityList) do
        local provider = ViceCity.GetProvider('banking')
        if provider and GetResourceState(provider.resource or providerName) == 'started' then
            return provider, providerName
        end
    end

    return nil, 'no_provider'
end

-- Set active banking adapter
local provider, selectedName = selectBankingProvider()
if provider then
    ViceCity.BankingAdapter = provider
    print(('Banking: Loaded %s'):format(selectedName))
else
    print('Banking: No provider found')
end

-- Export society functions for backwards compatibility
exports('SocietyCreate', function(name, label, type) return select(1, ViceCity.Society.Create(name, label, type)) end)
exports('SocietyEnsure', function(name, label, type) return select(1, ViceCity.Society.Ensure(name, label, type)) end)
exports('SocietyBalance', function(name) return ViceCity.Society.Balance(name) end)
exports('SocietyAddMoney',
    function(name, amount, reason, source) return select(1, ViceCity.Society.AddMoney(name, amount, reason, source)) end)
exports('SocietyRemoveMoney',
    function(name, amount, reason, source) return select(1, ViceCity.Society.RemoveMoney(name, amount, reason, source)) end)
exports('SocietyTransferMoney',
    function(from, to, amount, reason, source) return select(1,
            ViceCity.Society.TransferMoney(from, to, amount, reason, source)) end)
exports('SocietyHasAccess',
    function(source, name, role) return select(1, ViceCity.Society.HasAccess(source, name, role)) end)

-- Export banking functions for backwards compatibility
exports('BankingCreateAccount',
    function(type, name, label, owner) return select(1, ViceCity.Banking.ServerCreateAccount(type, name, label, owner)) end)
exports('BankingGetAccount', function(id) return select(1, ViceCity.Banking.ServerGetAccount(id)) end)
exports('BankingGetAccounts', function(owner, type) return select(1, ViceCity.Banking.ServerGetAccounts(owner, type)) end)
exports('BankingGetBalance', function(id) return select(1, ViceCity.Banking.ServerGetAccountBalance(id)) end)
exports('BankingAddMoney',
    function(id, amount, reason, source) return select(1, ViceCity.Banking.ServerAddMoney(id, amount, reason, source)) end)
exports('BankingRemoveMoney',
    function(id, amount, reason, source) return select(1, ViceCity.Banking.ServerRemoveMoney(id, amount, reason, source)) end)
exports('BankingTransferMoney',
    function(from, to, amount, reason, source) return select(1,
            ViceCity.Banking.ServerTransferMoney(from, to, amount, reason, source)) end)
