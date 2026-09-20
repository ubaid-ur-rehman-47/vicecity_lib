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

--client/core
Include('client/core/functions.lua')
Include('client/core/vehicle_functions.lua')

--client/framework
Include(('client/framework/%s.lua'):format(Cfg.Framework:lower()))
Include('client/framework/framework_functions.lua')

--client/integrations
Include('client/integrations/dead_cuffed_dragged.lua')
Include('client/integrations/dispatch.lua')
Include('client/integrations/drawtextui.lua')
Include('client/integrations/gang.lua')
Include('client/integrations/hud.lua')
Include('client/integrations/job_duty.lua')
Include('client/integrations/mechanic.lua')
Include('client/integrations/notifications.lua')
Include('client/integrations/persistent_vehicle.lua')
Include('client/integrations/street_names.lua')
Include('client/integrations/time_weather.lua')
Include('client/integrations/vehicle_fuel.lua')
Include('client/integrations/vehicle_keys.lua')
Include('client/integrations/vehicle_mileage.lua')
Include('client/integrations/vehicle_shop.lua')

if Cfg.BridgeDebug then
    DEBUG(('Client bridge loaded into: %s'):format(GetCurrentResourceName()))
end

BridgeLoaded = true