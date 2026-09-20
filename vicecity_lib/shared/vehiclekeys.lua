--[[
    Vehicle-keys layer (shared) — normalized key-operation and capability
    contract across all supported vehicle-key providers.

    Global API:
      ViceCity.VehicleKeys.*        client/server key operations
      ViceCity.VehicleKeysAdapter   registration point for custom providers
]]

ViceCity.VehicleKeys = ViceCity.VehicleKeys or {}

local KEY_OPERATIONS = {
    give = 'give',
    remove = 'remove',
    has = 'has',
    share = 'share',
    revoke = 'revoke',
    lock = 'lock',
    unlock = 'unlock',
    toggleLock = 'toggleLock',
    startIgnition = 'startIgnition',
    stopIgnition = 'stopIgnition',
}

local function unsupportedResult(operation, provider)
    return { ok = false, reason = 'unsupported', operation = operation, provider = provider }
end

local function forbiddenResult(operation, reason)
    return { ok = false, reason = reason or 'forbidden', operation = operation }
end

ViceCity.VehicleKeyOperations = KEY_OPERATIONS
ViceCity.VehicleKeysUnsupportedResult = unsupportedResult
ViceCity.VehicleKeysForbiddenResult = forbiddenResult

function ViceCity.VehicleKeys.GetProvider()
    return ViceCity.GetProvider('vehiclekeys') or 'none'
end

function ViceCity.VehicleKeys.GetCapabilities()
    local provider = ViceCity.VehicleKeysAdapter
    return provider and provider.capabilities or {}
end

GetVehicleKeysProvider = ViceCity.VehicleKeys.GetProvider
GetVehicleKeysCapabilities = ViceCity.VehicleKeys.GetCapabilities
