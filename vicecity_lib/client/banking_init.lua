--[[
    Banking layer initialization (client) — loads all banking provider adapters
]]

-- Ensure ViceCity exists
assert(ViceCity, 'ViceCity core not loaded')

-- Initialize banking adapter registry
ViceCity.BankingAdapter = nil

-- Load all provider adapters
local adapterFiles = {
    'okokbanking',
    'qb-banking',
}

for _, adapterName in ipairs(adapterFiles) do
    local path = ('client/banking/%s.lua'):format(adapterName)
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
        if provider and GetResourceState(provider.resource) == 'started' then
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
