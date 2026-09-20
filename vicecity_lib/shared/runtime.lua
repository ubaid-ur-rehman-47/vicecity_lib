ViceCity = ViceCity or {}
ViceCity.Version = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '0.1.0'
ViceCity.Context = IsDuplicityVersion() and 'server' or 'client'
ViceCity.Ready = false
ViceCity.Providers = ViceCity.Providers or {}
ViceCity.Resolved = ViceCity.Resolved or {}
ViceCity.Diagnostics = ViceCity.Diagnostics or {
    context = ViceCity.Context,
    startedAt = GetGameTimer(),
    warnings = {},
}

local function isDisabled(name)
    return ViceCityConfig.disabled[name] == true
end

local function resourceState(resource)
    if not resource then return 'missing' end
    return GetResourceState(resource)
end

function ViceCity.RegisterProvider(category, name, provider)
    assert(type(category) == 'string' and category ~= '', 'provider category is required')
    assert(type(name) == 'string' and name ~= '', 'provider name is required')
    assert(type(provider) == 'table', 'provider must be a table')

    ViceCity.Providers[category] = ViceCity.Providers[category] or {}
    ViceCity.Providers[category][name] = provider
    return true
end

function ViceCity.ResolveProvider(category, candidates)
    if isDisabled(category) then
        ViceCity.Resolved[category] = 'disabled'
        return nil
    end

    local configured = ViceCityConfig.providers[category]
    if configured and configured ~= 'auto' then
        if ViceCity.Providers[category] and ViceCity.Providers[category][configured] then
            ViceCity.Resolved[category] = configured
            return ViceCity.Providers[category][configured]
        end
        ViceCity.Diagnostics.warnings[#ViceCity.Diagnostics.warnings + 1] =
            ('Configured provider not registered: %s.%s'):format(category, configured)
        return nil
    end

    for _, candidate in ipairs(candidates or {}) do
        local provider = ViceCity.Providers[category] and ViceCity.Providers[category][candidate.name]
        if provider and (not candidate.resource or resourceState(candidate.resource) == 'started') then
            ViceCity.Resolved[category] = candidate.name
            return provider
        end
    end

    ViceCity.Resolved[category] = 'none'
    return nil
end

function ViceCity.GetVersion()
    return ViceCity.Version
end

function ViceCity.IsReady()
    return ViceCity.Ready
end

function ViceCity.GetProvider(category)
    return ViceCity.Resolved[category]
end

function ViceCity.GetFramework()
    return ViceCity.Framework
end

function ViceCity.GetDiagnostics()
    return {
        context = ViceCity.Diagnostics.context,
        ready = ViceCity.Ready,
        version = ViceCity.Version,
        resolved = ViceCity.Resolved,
        warnings = ViceCity.Diagnostics.warnings,
    }
end

function ViceCity.ResolveProviders()
    local frameworkCandidates = {}
    local frameworkResources = {
        qbox = 'qbx_core',
        qb = 'qb-core',
        esx = 'es_extended',
        standalone = nil,
    }
    for _, name in ipairs(ViceCityConfig.frameworkPriority or {}) do
        frameworkCandidates[#frameworkCandidates + 1] = {
            name = name,
            resource = frameworkResources[name],
        }
    end
    ViceCity.FrameworkAdapter = ViceCity.ResolveProvider('framework', frameworkCandidates)

    local inventoryResources = {
        ox = 'ox_inventory',
        qb = 'qb-inventory',
        qs = 'qs-inventory',
        codem = 'codem-inventory',
        codemv2 = 'codem-inventoryv2',
        core = 'core_inventory',
        tgiann = 'tgiann-inventory',
        origen = 'origen_inventory',
        ak47 = 'ak47_inventory',
        ak47qb = 'ak47_qb_inventory',
        jaksam = 'jaksam_inventory',
        jpr = 'jpr-inventory',
        ps = 'ps-inventory',
        lj = 'lj-inventory',
        esx = 'esx_inventory',
        s = 'S-inventory',
        native = nil,
    }
    local inventoryCandidates = {}
    for _, name in ipairs(ViceCityConfig.inventoryPriority or {}) do
        inventoryCandidates[#inventoryCandidates + 1] = {
            name = name,
            resource = inventoryResources[name],
        }
    end
    ViceCity.InventoryAdapter = ViceCity.ResolveProvider('inventory', inventoryCandidates)
    local appearanceResources = {
        ['17mov'] = '17mov_CharacterSystem',
        codem = 'codem-clothing',
        codemAppearance = 'codem-appearance',
        illenium = 'illenium-appearance',
        qb = 'qb-clothing',
        esx = 'esx_skin',
        skinchanger = 'skinchanger',
        fivem = 'fivem-appearance',
        qs = 'qs-appearance',
        ['4bit'] = '4bit_appearance',
        qf = 'qf_skinmenu',
        crm = 'crm-appearance',
        tgiann = 'tgiann-clothing',
        rcore = 'rcore_clothing',
        ['0r'] = '0r-clothing',
        native = nil,
    }
    local appearanceCandidates = {}
    local appearanceConfig = ViceCityConfig.appearance or {}
    for _, name in ipairs(appearanceConfig.priority or {}) do
        appearanceCandidates[#appearanceCandidates + 1] = {
            name = name,
            resource = appearanceResources[name],
        }
    end
    local configuredAppearance = appearanceConfig.provider
    if configuredAppearance and configuredAppearance ~= 'auto' then
        appearanceCandidates = {{ name = configuredAppearance, resource = appearanceResources[configuredAppearance] }}
    end
    ViceCity.AppearanceAdapter = ViceCity.ResolveProvider('appearance', appearanceCandidates)
    ViceCity.ResolveProvider('database', {
        { name = 'none' },
    })
end

function ViceCity.Start()
    if ViceCity.Ready then return true end
    ViceCity.ResolveProviders()
    ViceCity.Ready = true
    if ViceCityConfig.debug then
        print(('[vicecity_lib] ready (%s) v%s'):format(ViceCity.Context, ViceCity.Version))
    end
    return true
end

GetVersion = ViceCity.GetVersion
IsReady = ViceCity.IsReady
GetProvider = ViceCity.GetProvider
GetDiagnostics = ViceCity.GetDiagnostics
RegisterProvider = ViceCity.RegisterProvider
GetFramework = function()
    return ViceCity.Framework
end
