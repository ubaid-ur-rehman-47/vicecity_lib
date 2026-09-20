-- ┌──────────────────────────────────────────────────────────────────┐
-- │                      REMOTE ERROR REPORTING                      │
-- └──────────────────────────────────────────────────────────────────┘

local caughtErrors = {}

local function storeError(error_code, origin, reason, expected_type, actual_type, value, report_type)
    local type_check = expected_type and ('%s expected, got %s : [%s]'):format(expected_type, actual_type, tostring(value)) or nil
    local callResource = GetCallResource() or 'unknown'
    local version = callResource ~= 'unknown' and GetResourceMetadata(callResource, 'version', 0) or 'unknown'
    local title = ('%s v%s - client'):format(callResource, version)

    caughtErrors[#caughtErrors + 1] = {
        error_code = error_code,
        report_type = report_type or (expected_type and 'typecheck' or 'error'),
        type_check = type_check,
        origin = origin,
        reason = reason,
        title = title,
        timestamp = GetCloudTimeAsInt()
    }
    return #caughtErrors
end
exports('StoreError', storeError)
exports('GetErrors', function()
    return caughtErrors or {}
end)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          PRE START CHECKS                        │
-- └──────────────────────────────────────────────────────────────────┘ 

CreateThread(function()
    Wait(2000)
    WaitForErrorHandlingToLoad()

    if Cfg.BridgeDebug then
        PrintDebugErrorCommands()
    end
end)
