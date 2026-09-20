local BRIDGE = 'cd_bridge'
BridgeLoaded = false

if GetCurrentResourceName() == BRIDGE then
    return
end

local function Include(path)
    local content = LoadResourceFile(BRIDGE, path)
    if not content then
        local message = ('[%s] Failed to load file: %s'):format(BRIDGE, path)
        if BridgeReportStartupError then BridgeReportStartupError(message, BRIDGE..'/'..path) end
        error(message, 0)
    end

    local fn, err = load(content, ('@%s/%s'):format(BRIDGE, path))
    if not fn then
        if BridgeReportStartupError then BridgeReportStartupError(err, BRIDGE..'/'..path) end
        error(err, 0)
    end

    local ok, runtimeErr = xpcall(fn, BridgeStartupErrorHandler or debug.traceback)
    if not ok then error(runtimeErr, 0) end
end

--shared
Include('shared/startup_error_handler.lua')
Include('locales/lua/shared.lua')
Include('shared/debug.lua')
Include('shared/error_handling.lua')
Include('shared/functions.lua')
Include('shared/vehicle_functions.lua')

--server/core
Include('server/core/database.lua')
Include('server/core/functions.lua')
Include('server/core/vehicle_functions.lua')

--server/framework
Include(('server/framework/%s.lua'):format(Cfg.Framework:lower()))
Include('server/framework/framework_functions.lua')

--server/integrations
Include(('server/integrations/inventory/%s.lua'):format(Cfg.Inventory:lower()))
Include('server/integrations/inventory/shared_inventory_functions.lua')
Include('server/integrations/banking.lua')
Include('server/integrations/billing.lua')
Include('server/integrations/callsign.lua')
Include('server/integrations/gang.lua')
Include('server/integrations/job_duty.lua')
Include('server/integrations/phone_number.lua')
Include('server/integrations/society.lua')
Include('server/integrations/vehicle_keys.lua')
Include('server/integrations/vehicle_mileage.lua')
Include('server/integrations/vehicle_shop.lua')

if Cfg.BridgeDebug then
    DEBUG(('Server bridge loaded into: %s'):format(GetCurrentResourceName()))
end

BridgeLoaded = true