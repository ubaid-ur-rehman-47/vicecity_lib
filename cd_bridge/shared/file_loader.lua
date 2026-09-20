local sharedFiles = {
    'shared/startup_error_handler.lua',
    'shared/error_handling.lua',
    'shared/debug.lua',
    'shared/config.lua',
    'locales/lua/shared.lua',
    'shared/error_handling.lua',
    'shared/auto_detect.lua',
    'shared/functions.lua',
    'shared/vehicle_functions.lua',
}

local clientFiles = {
    'client/core/error_handling.lua',
    'client/core/debug.lua',
    'client/core/callbacks.lua',
    'client/core/draw_interact_image.lua',
    'client/core/functions.lua',
    'client/core/startup_config_validation.lua',
    'client/core/vehicle_functions.lua',
    'client/integrations/dead_cuffed_dragged.lua',
    'client/integrations/dispatch.lua',
    'client/integrations/drawtextui.lua',
    'client/integrations/gang.lua',
    'client/integrations/hud.lua',
    'client/integrations/job_duty.lua',
    'client/integrations/mechanic.lua',
    'client/integrations/notifications.lua',
    'client/integrations/persistent_vehicle.lua',
    'client/integrations/street_names.lua',
    'client/integrations/time_weather.lua',
    'client/integrations/vehicle_fuel.lua',
    'client/integrations/vehicle_keys.lua',
    'client/integrations/vehicle_mileage.lua',
    'client/integrations/vehicle_shop.lua',
}

local serverFiles = {
    'server/core/error_handling.lua',
    'server/core/debug.lua',
    'server/core/auto_restart.lua',
    'server/core/database.lua',
    'server/core/callbacks.lua',
    'server/core/startup_config_validation.lua',
    'server/core/functions.lua',
    'server/core/vehicle_functions.lua',
    'server/core/version_check.lua',
    'server/integrations/banking.lua',
    'server/integrations/billing.lua',
    'server/integrations/callsign.lua',
    'server/integrations/gang.lua',
    'server/integrations/job_duty.lua',
    'server/integrations/notifications.lua',
    'server/integrations/phone_number.lua',
    'server/integrations/society.lua',
    'server/integrations/vehicle_keys.lua',
    'server/integrations/vehicle_mileage.lua',
    'server/integrations/vehicle_shop.lua',
}

local resourceName = GetCurrentResourceName()
local runtimeSide = IsDuplicityVersion() and 'server' or 'client'

local function reportError(message, path)
    if BridgeReportStartupError then
        BridgeReportStartupError(message, path)
    else
        Citizen.Trace(('^1[%s] %s: %s^0\n'):format(resourceName, path, tostring(message)))
    end
end

local function runChunk(chunk, path)
    Citizen.CreateThreadNow(function()
        xpcall(chunk, function(errorMessage)
            if BridgeStartupErrorHandler then
                return BridgeStartupErrorHandler(errorMessage, path)
            end
            local traceback = debug.traceback(tostring(errorMessage), 2)
            reportError(traceback, path)
            return traceback
        end)
    end, '@'..resourceName..'/'..path)
end

local function loadFile(path)
    local source = LoadResourceFile(resourceName, path)
    if not source then
        reportError('File could not be read', path)
        return false
    end

    local chunk, err = load(source, '@'..resourceName..'/'..path, 't', _ENV)
    if not chunk then
        reportError(err, path)
        return false
    end

    runChunk(chunk, path)

    return true
end

for _, path in ipairs(sharedFiles) do
    loadFile(path)
end

for _, path in ipairs(runtimeSide == 'server' and serverFiles or clientFiles) do
    loadFile(path)
end

runChunk(function()
    loadFile(('%s/framework/%s.lua'):format(runtimeSide, Cfg.Framework:lower()))
    loadFile(runtimeSide..'/framework/framework_functions.lua')

    if runtimeSide == 'server' then
        loadFile(('server/integrations/inventory/%s.lua'):format(Cfg.Inventory:lower()))
        loadFile('server/integrations/inventory/shared_inventory_functions.lua')
    end
end, 'shared/file_loader.lua')