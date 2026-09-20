-- ┌──────────────────────────────────────────────────────────────────┐
-- │                           AUTO RESTART                           │
-- └──────────────────────────────────────────────────────────────────┘ 

local bridgeName = GetCurrentResourceName()
local CheckingDependencies = {}
local RequiredDependencies = {
    cd_dispatch3d = { 'cd_bridge' },
    cd_doorlock = { 'cd_bridge' },
    cd_eventcalendar = { 'cd_bridge' },
    cd_hud = { 'cd_bridge' },
    cd_mechanic = { 'cd_bridge', 'cd_mechanic_props', 'cd_torquemaster' },
    cd_vipshop = { 'cd_bridge' },
    cd_cctv = { 'cd_bridge' },
    cd_garage = {
        'cd_bridge',
        {
            name = 'cd_garageshell',
            enabled = function()
                local success, loaded
                repeat
                    success, loaded = pcall(function() return exports.cd_garage:HasDatabaseConfigLoaded() end)
                    if not success then Wait(100) end
                until success
                if not loaded then return nil end
                local config = exports.cd_garage:GetConfig()
                return config.InsideGarage and config.InsideGarage.ENABLE == true
            end,
        },
    },
}

local function consolePrint(resName, dependencyName)
    Citizen.Trace(Locale('dependancy_missing'):format( resName, dependencyName, dependencyName, dependencyName, dependencyName, dependencyName) .. '^0\n')
end

local function checkDependencies(resName)
    if CheckingDependencies[resName] then return end
    local check = {}
    CheckingDependencies[resName] = check

    CreateThread(function()
        Wait(1000)
        for _, dependency in ipairs(RequiredDependencies[resName] or { 'cd_bridge' }) do
            if CheckingDependencies[resName] ~= check then return end
            local dependencyName = type(dependency) == 'table' and dependency.name or dependency
            local enabled = true

            if type(dependency) == 'table' and dependency.enabled then
                local timeout = GetGameTimer() + 60000
                local lastError
                repeat
                    if CheckingDependencies[resName] ~= check then return end
                    if GetResourceState(resName) ~= 'started' then
                        CheckingDependencies[resName] = nil
                        return
                    end
                    local ok, result = pcall(dependency.enabled)
                    lastError = not ok and tostring(result) or nil
                    enabled = ok and result
                    if ok and result ~= nil then break end
                    enabled = nil
                    Wait(250)
                until GetGameTimer() >= timeout

                if enabled == nil then
                    Citizen.Trace(('^3[%s] Could not check dependency %s: %s.^0\n'):format(
                        resName, dependencyName, lastError or 'configuration was not ready within 60 seconds'
                    ))
                end
            end

            if enabled and GetResourceState(resName) == 'started' then
                local state = GetResourceState(dependencyName)
                -- A removed resource can still have a cached started/stopped state
                -- until the server refreshes its resource list.
                local installed = LoadResourceFile(dependencyName, 'fxmanifest.lua')
                    or LoadResourceFile(dependencyName, '__resource.lua')
                if not installed then
                    state = 'missing'
                elseif state == 'stopped' then
                    StartResource(dependencyName)
                    state = GetResourceState(dependencyName)
                end
                if state ~= 'started' and state ~= 'starting' then
                    consolePrint(resName, dependencyName)
                end
            end
        end
        if CheckingDependencies[resName] == check then
            CheckingDependencies[resName] = nil
        end
    end)
end

AddEventHandler('onResourceStop', function(resName)
    CheckingDependencies[resName] = nil
end)

local function safeStartResource(resName)
    local state = GetResourceState(resName)

    if state == 'missing' then
        return
    end

    if state == 'stopped' then
        local ok = StartResource(resName)
        if Cfg.BridgeDebug then
            AUTOFIX(('[%s] StartResource(%s) -> %s'):format(bridgeName, resName, tostring(ok)))
        end
    end
    if GetResourceState(resName) == 'started' then
        checkDependencies(resName)
    end
end

AddEventHandler('onResourceStart', function(resName)
    if DependantResources[resName] or RequiredDependencies[resName] then
        Wait(1000)
        checkDependencies(resName)
    end
    if resName ~= bridgeName then return end

    CreateThread(function()
        Wait(500)

        for res, _ in pairs(DependantResources) do
            safeStartResource(res)
        end
        for res in pairs(RequiredDependencies) do
            if not DependantResources[res] and GetResourceState(res) == 'started' then
                checkDependencies(res)
            end
        end
    end)
end)

-- ┌──────────────────────────────────────────────────────────────────┐
-- │                          RESTART RESOURCE                        │
-- └──────────────────────────────────────────────────────────────────┘

local RestartingResources = {}
local AllowedRestartResources = {
    cd_garage = true,
}
local AllowedInvokingResources = {
    cd_garage = true,
}
RegisterServerEvent('cd_bridge:RestartResource', function(resName, hudVisibilityWasDisabled)
    local src = source

    if not TypeCheck(resName, 'string', '642', 'resName nil in cd_bridge:RestartResource') then
        return
    end

    if AllowedInvokingResources[GetInvokingResource()] ~= true then
        WARN('6941', ''..GetInvokingResource()..' tried to restart resource '..resName..' without permission')
        return
    end

    if type(src) == 'number' and src > 0 then
        WARN('3542', ''..src..' tried to restart resource '..resName..' without permission')
        return
    end

    if not AllowedRestartResources[resName] then
        WARN('4562', 'Blocked restart for resource '..resName)
        return
    end

    if GetResourceState(resName) == 'missing' then
        WARN('6632', 'Resource '..resName..' does not exist')
        return
    end

    if RestartingResources[resName] then
        return
    end

    RestartingResources[resName] = true

    CreateThread(function()
        StopResource(resName)

        local timeout = GetGameTimer() + 10000
        while GetResourceState(resName) ~= 'stopped' and GetGameTimer() < timeout do
            Wait(100)
        end

        if GetResourceState(resName) == 'stopped' then
            Wait(1000)
            StartResource(resName)
            if hudVisibilityWasDisabled then
                TriggerClientEvent('cd_bridge:SetHudVisibility', -1, true)
            end
        else
            WARN('5232', 'Timed out stopping resource '..resName)
        end

        RestartingResources[resName] = nil
    end)
end)
