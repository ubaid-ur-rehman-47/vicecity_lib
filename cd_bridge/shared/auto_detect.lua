CurrentResourceName = GetCurrentResourceName()
DependantResources = {
    ['cd_dispatch3d'] = true,
    ['cd_doorlock'] = true,
    ['cd_eventcalendar'] = true,
    ['cd_garage'] = true,
    ['cd_mechanic'] = true,
    ['cd_vipshop'] = true,
    ['cd_cctv'] = true,
    ['cd_hud'] = true
}

local AutoDetectResources = {
    Framework = {
        esx = 'es_extended',
        qbox = 'qbx_core',
        qbcore = 'qb-core',
        vrp = 'vRP',
    },
    Database = {
        'oxmysql',
        'ghmattimysql',
    },
    Banking = {
        'fd_banking',
        'ns_SolarBanking',
        'okokBanking',
        'omes_banking',
        'p_banking',
        'ps-banking',
        'qb-banking',
        'Renewed-Banking',
        'RxBanking',
        'tgg-banking',
        'wasabi_banking',
        'esx_banking',
    },
    Billing = {
        'codem_billing',
        'codem-billingv2',
        'okokBilling',
        'esx_billing',
    },
    Dispatch = {
        'cd_dispatch3d',
        'cd_dispatch',
        'codem-dispatch',
        'codem-mdtv2',
        'core_dispatch',
        'emergencydispatch',
        'lb-tablet',
        'origen_police',
        'ps-dispatch',
        'qs-dispatch',
        'rcore_dispatch',
        'tk_dispatch',
    },
    DrawTextUI = {
        'cd_drawtextui',
        'jg-textui',
        'ox_lib',
        'okokTextUI',
        'ps-ui',
        'tgiann-core',
        'vms_notifyv2',
        'ZSX_UIV2',
        'esx_textui',
        'qb-core',
    },
    Duty = {
        'core_multijob',
        'jobs_creator',
        'origen_police',
    },
    Gang = {
        'av_gangs',
        'rcore_gangs',
    },
    Hud = {
        'Codem-BlackHUDV2',
        'izzy-hudv5',
        'izzy-hudv6',
        'izzy-hudv7',
        'jg-hud',
        'lation_ui',
        'mHud',
        'tgiann-lumihud',
        'vms_hud',
        'wais-hudv6',
        '0r-hud-v3',
        '17mov_Hud',
        'esx_hud',
    },
    Inventory = {
        'ak47_inventory',
        'ak47_qb_inventory',
        'chezza-inventory',
        'codem-inventory',
        'core_inventory',
        'jaksam_inventory',
        'jpr-inventory',
        'origen_inventory',
        'ps-inventory',
        'qs-inventory',
        'tgiann-inventory',
        'ox_inventory',
        'esx_inventory',
        'qb-inventory',
    },
    Mechanic = {
        'cd_mechanic',
        'jg-mechanic',
    },
    Notification = {
        'cd_notifications',
        'codem-notification',
        'codem-supreme-notification',
        'mythic_notify',
        'okokNotify',
        'origen_notify',
        'ox_lib',
        'pNotify',
        'ps-ui',
        'rtx_notify',
        'tgiann-lumihud',
        'vms_notifyv2',
        'ZSX_UI',
        'ZSX_UIV2',
        '17mov_Hud',
    },
    PersistentVehicles = {
        'cd_garage',
        'AdvancedParking',
    },
    Phone = {
        'gcphone',
        'gksphone',
        'high-phone',
        'lb-phone',
        'npwd',
        'ns_Phone',
        'okokPhone',
        'qs-smartphone',
        'qs-smartphone-pro',
        'roadphone',
        'sd-phone',
        'yseries',
        '17mov_Phone',
        'esx_phone',
        'qb-phone',
        'qbx_npwd',
    },
    Society = {
        'fd_banking',
        'ns_SolarBanking',
        'okokBanking',
        'p_banking',
        'Renewed-Banking',
        'RxBanking',
        'tgg-banking',
        'tgiann-bank',
        'wasabi_banking',
        'esx_society',
        'qb-banking',
    },
    Target = {
        'ox_target',
        'qb-target',
    },
    TimeWeather = {
        'cd_easytime',
        'codem-dynamicweather',
        'vsync',
        'qb-weathersync',
    },
    VehicleFuel = {
        'BigDaddy-Fuel',
        'cdn-fuel',
        'esx-sna-fuel',
        'FRFuel',
        'lc_fuel',
        'LegacyFuel',
        'lj-fuel',
        'lyre_fuel',
        'mnr_fuel',
        'myFuel',
        'ND_Fuel',
        'okokGasStation',
        'ox_fuel',
        'ps-fuel',
        'qb-sna-fuel',
        'qs-fuelstations',
        'rcore_fuel',
        'Renewed-Fuel',
        'ti_fuel',
        'x-fuel',
        'qb-fuel',
    },
    VehicleKeys = {
        'ak47_qb_vehiclekeys',
        'ak47_vehiclekeys',
        'fast-vehiclekeys',
        'fivecode_carkeys',
        'F_RealCarKeysSystem',
        'ic3d_vehiclekeys',
        'is_vehiclekeys',
        'jc_vehiclekeys',
        'loaf_keysystem',
        'mk_vehiclekeys',
        'mm_carkeys',
        'MrNewbVehicleKeys',
        'mx_carkeys',
        'qs-vehiclekeys',
        'Renewed-Vehiclekeys',
        'stasiek_vehiclekeys',
        'tc_keys',
        't1ger_keys',
        'tgiann-hotwire',
        'ti_vehicleKeys',
        'vehicles_keys',
        'wasabi_carlock',
        'xd_locksystem',
        'qbx_vehiclekeys',
        'qb-vehiclekeys',
        'cd_garage',
    },
    VehicleMileage = {
        'cd_mechanic',
        'cd_garage',
        'jg-vehiclemileage',
    },
    VehicleShop = {
        'cd_vehicleshop',
        'dealerships_creator',
        'jg-dealerships',
        'okokVehicleShop',
        'qs-vehicleshop',
        'vms_vehicleshopv2',
        'esx_vehicleshop',
        'qb-vehicleshop',
        'qbx-vehicleshop',
    }
}

local ConfigBeforeAutoDetect = {
    Framework = Cfg.Framework,
    Database = Cfg.Database,
    Banking = Cfg.Banking,
    Billing = Cfg.Billing,
    Dispatch = Cfg.Dispatch,
    DrawTextUI = Cfg.DrawTextUI,
    Duty = Cfg.Duty,
    Gang = Cfg.Gang,
    Hud = Cfg.Hud,
    Inventory = Cfg.Inventory,
    Mechanic = Cfg.Mechanic,
    Notification = Cfg.Notification,
    PersistentVehicles = Cfg.PersistentVehicles,
    Phone = Cfg.Phone,
    Society = Cfg.Society,
    Target = Cfg.Target,
    TimeWeather = Cfg.TimeWeather,
    VehicleFuel = Cfg.VehicleFuel,
    VehicleKeys = Cfg.VehicleKeys,
    VehicleMileage = Cfg.VehicleMileage,
    VehicleShop = Cfg.VehicleShop,
}

local resourceAliases = {
    ['chezza-inventory'] = 'esx_inventory',
    ['ak47_qb_inventory'] = 'ak47_inventory',
}

local frameworkStartupChecked = false
local frameworkStartupResource
local frameworkStartupReady = false
local frameworkErrors = {}
local frameworkRestartInstructions = ' Ensure your framework is started before cd_bridge in server.cfg.'

local function running(res)
    return GetResourceState(res) == 'started' or GetResourceState(res) == 'starting'
end

local function detect(list, fallback)
    for _, res in ipairs(list) do
        if running(res) then
            return res
        end
    end
    return fallback
end

local function resourceAffectsBridge(resName)
    for cfgKey, resources in pairs(AutoDetectResources) do
        for _, resource in pairs(resources) do
            if resource == resName then
                return cfgKey
            end
        end
    end
    return nil
end

local function resourceMatchesActiveConfig(cfgKey, resourceName)
    local active = Cfg[cfgKey]

    if active == resourceName then
        return true
    end

    if resourceAliases[resourceName] and resourceAliases[resourceName] == active then
        return true
    end

    return false
end

local function runAutoDetect()
    if Cfg.Framework == 'auto_detect' then
        for framework, resourceName in pairs(AutoDetectResources.Framework) do
            if running(resourceName) then
                Cfg.Framework = framework
                break
            end
        end
        if Cfg.Framework == 'auto_detect' then Cfg.Framework = 'standalone' end
    end

    if not frameworkStartupChecked then
        frameworkStartupChecked = true
        frameworkStartupResource = AutoDetectResources.Framework[Cfg.Framework]
        frameworkStartupReady = frameworkStartupResource ~= nil and GetResourceState(frameworkStartupResource) == 'started'
        if CurrentResourceName == 'cd_bridge' then
            local message
            if ConfigBeforeAutoDetect.Framework == 'auto_detect' and not frameworkStartupResource then
                local unavailableFrameworks = {}
                for _, resource in pairs(AutoDetectResources.Framework) do
                    local state = GetResourceState(resource)
                    if state ~= 'missing' then
                        unavailableFrameworks[#unavailableFrameworks + 1] = ('%s (%s)'):format(resource, state)
                    end
                end
                if #unavailableFrameworks > 0 then
                    message = 'Framework resources were present but not ready when cd_bridge loaded: '..table.concat(unavailableFrameworks, ', ')..'.'
                end
            elseif frameworkStartupResource and not frameworkStartupReady then
                message = ('Framework %s was not ready when cd_bridge loaded (state: %s).'):format(frameworkStartupResource, GetResourceState(frameworkStartupResource))
            end

            if message then
                message = message..frameworkRestartInstructions
                WaitForErrorHandlingToLoad()
                ERROR('FRAMEWORK_STARTUP_ORDER', message)
            end
        end
    end

    if Cfg.Database == 'auto_detect' or (Cfg.Database == 'none' and ConfigBeforeAutoDetect.Database == 'auto_detect') then
        Cfg.Database = detect(AutoDetectResources.Database, 'none')
    end

    if Cfg.Banking == 'auto_detect' or (Cfg.Banking == 'none' and ConfigBeforeAutoDetect.Banking == 'auto_detect') then
        Cfg.Banking = detect(AutoDetectResources.Banking, 'none')
    end

    if Cfg.Billing == 'auto_detect' or (Cfg.Billing == 'none' and ConfigBeforeAutoDetect.Billing == 'auto_detect') then
        Cfg.Billing = detect(AutoDetectResources.Billing, 'none')
    end

    if Cfg.Dispatch == 'auto_detect' or (Cfg.Dispatch == 'none' and ConfigBeforeAutoDetect.Dispatch == 'auto_detect') then
        Cfg.Dispatch = detect(AutoDetectResources.Dispatch, 'none')
    end

    if Cfg.DrawTextUI == 'auto_detect' or (Cfg.DrawTextUI == 'none' and ConfigBeforeAutoDetect.DrawTextUI == 'auto_detect') then
        Cfg.DrawTextUI = detect(AutoDetectResources.DrawTextUI, 'none')
    end

   if Cfg.Duty == 'auto_detect' or (Cfg.Duty == 'none' and ConfigBeforeAutoDetect.Duty == 'auto_detect') then
        Cfg.Duty = detect(AutoDetectResources.Duty, 'none')

        if Cfg.Duty == 'core_multijob' then
            Cfg.DisableDuty = true
            if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
                AUTOFIX(('Detected %s for duty, setting Cfg.DisableDuty to true.\n'):format(Cfg.Duty))
            end
        end
    end

    if Cfg.Gang == 'auto_detect' or (Cfg.Gang == 'none' and ConfigBeforeAutoDetect.Gang == 'auto_detect') then
        Cfg.Gang = detect(AutoDetectResources.Gang, 'none')
    end

    if Cfg.Hud == 'auto_detect' or (Cfg.Hud == 'none' and ConfigBeforeAutoDetect.Hud == 'auto_detect') then
        Cfg.Hud = detect(AutoDetectResources.Hud, 'none')
    end

    if Cfg.Inventory == 'auto_detect' or (Cfg.Inventory == 'none' and ConfigBeforeAutoDetect.Inventory == 'auto_detect') then
        local inventory = detect(AutoDetectResources.Inventory, nil)

        if inventory then
            Cfg.Inventory = inventory
            if Cfg.Inventory == 'chezza-inventory' then
                Cfg.Inventory = 'esx_inventory'
            end
            if Cfg.Inventory == 'ak47_qb_inventory' then
                Cfg.Inventory = 'ak47_inventory'
            end
        else
            if Cfg.Framework == 'esx' then
                Cfg.Inventory = 'esx_inventory'
            elseif Cfg.Framework == 'qbcore' then
                Cfg.Inventory = 'qb-inventory'
            elseif Cfg.Framework == 'qbox' then
                Cfg.Inventory = 'ox_inventory'
            else
                Cfg.Inventory = 'none'
            end
            if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
                AUTOFIX(('No supported inventory detected, defaulting to %s.\n'):format(Cfg.Inventory))
            end
        end
    end

    if Cfg.Mechanic == 'auto_detect' or (Cfg.Mechanic == 'none' and ConfigBeforeAutoDetect.Mechanic == 'auto_detect') then
        Cfg.Mechanic = detect(AutoDetectResources.Mechanic, 'none')
    end

    if Cfg.Notification == 'auto_detect' or (Cfg.Notification == 'none' and ConfigBeforeAutoDetect.Notification == 'auto_detect') then
        local notif = detect(AutoDetectResources.Notification, nil)

        if notif then
            Cfg.Notification = notif
        else
            if Cfg.Framework == 'esx' or Cfg.Framework == 'qbcore' or Cfg.Framework == 'qbox' then
                Cfg.Notification = Cfg.Framework
            else
                Cfg.Notification = 'chat'
            end
            if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
                AUTOFIX(('No supported notification detected — defaulting to %s.\n'):format(Cfg.Notification))
            end
        end
    end

    if Cfg.PersistentVehicles == 'auto_detect' or (Cfg.PersistentVehicles == 'none' and ConfigBeforeAutoDetect.PersistentVehicles == 'auto_detect') then
        Cfg.PersistentVehicles = detect(AutoDetectResources.PersistentVehicles, 'none')
    end

    if Cfg.Phone == 'auto_detect' or (Cfg.Phone == 'none' and ConfigBeforeAutoDetect.Phone == 'auto_detect') then
        Cfg.Phone = detect(AutoDetectResources.Phone, 'none')
    end

    if Cfg.Society == 'auto_detect' or (Cfg.Society == 'none' and ConfigBeforeAutoDetect.Society == 'auto_detect') then
        Cfg.Society = detect(AutoDetectResources.Society, 'none')
    end

    if Cfg.Target == 'auto_detect' or (Cfg.Target == 'none' and ConfigBeforeAutoDetect.Target == 'auto_detect') then
        Cfg.Target = detect(AutoDetectResources.Target, 'none')
    end

    if Cfg.TimeWeather == 'auto_detect' or (Cfg.TimeWeather == 'none' and ConfigBeforeAutoDetect.TimeWeather == 'auto_detect') then
        Cfg.TimeWeather = detect(AutoDetectResources.TimeWeather, 'none')
    end

    if Cfg.VehicleFuel == 'auto_detect' or (Cfg.VehicleFuel == 'none' and ConfigBeforeAutoDetect.VehicleFuel == 'auto_detect') then
        Cfg.VehicleFuel = detect(AutoDetectResources.VehicleFuel, 'none')
    end

    if Cfg.VehicleKeys == 'auto_detect' or (Cfg.VehicleKeys == 'none' and ConfigBeforeAutoDetect.VehicleKeys == 'auto_detect') then
        Cfg.VehicleKeys = detect(AutoDetectResources.VehicleKeys, 'none')
    end

    if Cfg.VehicleMileage == 'auto_detect' or (Cfg.VehicleMileage == 'none' and ConfigBeforeAutoDetect.VehicleMileage == 'auto_detect') then
        Cfg.VehicleMileage = detect(AutoDetectResources.VehicleMileage, 'none')
    end

    if Cfg.VehicleShop == 'auto_detect' or (Cfg.VehicleShop == 'none' and ConfigBeforeAutoDetect.VehicleShop == 'auto_detect') then
        Cfg.VehicleShop = detect(AutoDetectResources.VehicleShop, 'none')
    end

    --framework specific SQL table configurations.
    if Cfg.Framework == 'esx' then
        Cfg.FrameworkSQLtables = {
            vehicle_table = 'owned_vehicles',
            vehicle_identifier = 'owner',
            vehicle_props = 'vehicle',
            vehicle_mileage = 'mileage',

            vehicle_garageid = 'parking',
            vehicle_garagetype = 'type',
            vehicle_state = 'stored',
            vehicle_impound = 'pound',

            users_table = 'users',
            users_identifier = 'identifier'
        }

    elseif Cfg.Framework == 'qbcore' then
        Cfg.FrameworkSQLtables = {
            vehicle_table = 'player_vehicles',
            vehicle_identifier = 'citizenid',
            vehicle_props = 'mods',
            vehicle_mileage = 'drivingdistance',

            vehicle_garageid = 'garage',
            vehicle_garagetype = nil,
            vehicle_state = 'state',
            vehicle_impound = nil,

            users_table = 'players',
            users_identifier = 'citizenid',
        }

    elseif Cfg.Framework == 'qbox' then
        Cfg.FrameworkSQLtables = {
            vehicle_table = 'player_vehicles',
            vehicle_identifier = 'citizenid',
            vehicle_props = 'mods',
            vehicle_mileage = 'drivingdistance',

            vehicle_garageid = 'garage',
            vehicle_garagetype = nil,
            vehicle_state = 'state',
            vehicle_impound = nil,

            users_table = 'players',
            users_identifier = 'citizenid',
        }

    elseif Cfg.Framework == 'other' or Cfg.Framework == 'vrp' or Cfg.Framework == 'standalone' then
        Cfg.FrameworkSQLtables = {
            vehicle_table = 'owned_vehicles',
            vehicle_identifier = 'owner',
            vehicle_props = 'vehicle',
            vehicle_mileage = 'mileage',

            vehicle_garageid = nil,
            vehicle_garagetype = nil,
            vehicle_state = nil,
            vehicle_impound = nil,

            users_table = 'users',
            users_identifier = 'identifier',
        }
    end
    FW = Cfg.FrameworkSQLtables
end

runAutoDetect()

local function detectResourceStart(resourceName)
    if resourceName == CurrentResourceName then return end

    for _, frameworkResource in pairs(AutoDetectResources.Framework) do
        if resourceName == frameworkResource then
            if (ConfigBeforeAutoDetect.Framework == 'auto_detect' and not frameworkStartupReady)
                or (resourceName == frameworkStartupResource and not frameworkStartupReady) then
                if CurrentResourceName == 'cd_bridge' and IsDuplicityVersion() and not frameworkErrors['start:'..resourceName] then
                    frameworkErrors['start:'..resourceName] = true
                    local message = ('Framework %s started after cd_bridge had already selected %s; a full server restart is required.'):format(resourceName, Cfg.Framework)..frameworkRestartInstructions
                    BridgeReportStartupError(message, 'shared/auto_detect.lua')
                    ERROR('FRAMEWORK_STARTUP_ORDER', message)
                end
            end

            if ConfigBeforeAutoDetect.Framework == 'auto_detect' or resourceName == frameworkStartupResource then
                return
            end
            break
        end
    end

    if resourceName == 'cd_garage' then
        local timeout = 5000
        local waited = 0

        while GetResourceState('cd_garage') ~= 'started' and waited < timeout do
            Wait(100)
            waited = waited + 100
        end

        if GetResourceState('cd_garage') ~= 'started' then
            if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
                DEBUG('cd_garage failed to start within timeout.')
            end
            return
        end

        local ok, config = pcall(function()
            return exports.cd_garage:GetConfig()
        end)

        if ok and config ~= nil then
            if ConfigBeforeAutoDetect.VehicleKeys == 'auto_detect' and config.VehicleKeys.ENABLE then
                Cfg.VehicleKeys = 'cd_garage'
            end

            if ConfigBeforeAutoDetect.PersistentVehicles == 'auto_detect' and config.PersistentVehicles.ENABLE then
                Cfg.PersistentVehicles = 'cd_garage'
            end

            if ConfigBeforeAutoDetect.VehicleMileage == 'auto_detect' and config.Mileage then
                if GetResourceState('cd_mechanic') == 'started' then
                    Cfg.VehicleMileage = 'cd_mechanic'
                else
                    Cfg.VehicleMileage = 'cd_garage'
                end
            end
        end
    end

    local cfgKey = resourceAffectsBridge(resourceName)

    if cfgKey and (ConfigBeforeAutoDetect[cfgKey] == 'auto_detect' or Cfg[cfgKey] == 'none') then
        if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
           DEBUG(('Detected supported resource start: %s (affects %s) — re-running auto detect.'):format(resourceName, cfgKey))
        end

        runAutoDetect()
    end

    if (resourceName == 'cd_garage' or resourceName == 'cd_mechanic') and ConfigBeforeAutoDetect.VehicleMileage == 'auto_detect' and GetResourceState('cd_mechanic') == 'started' then
        Cfg.VehicleMileage = 'cd_mechanic'
    end
end

local function detectResourceStop(resourceName)
    if resourceName == CurrentResourceName then return end

    if resourceName == frameworkStartupResource then
        frameworkStartupReady = false
        if CurrentResourceName == 'cd_bridge' and IsDuplicityVersion() and not frameworkErrors['stop:'..resourceName] then
            frameworkErrors['stop:'..resourceName] = true
            local message = ('Framework %s stopped while cd_bridge was running; its loaded adapter is no longer reliable.'):format(resourceName)..frameworkRestartInstructions
            BridgeReportStartupError(message, 'shared/auto_detect.lua')
            ERROR('FRAMEWORK_STOPPED', message)
        end
        return
    end

    local cfgKey = resourceAffectsBridge(resourceName)
    if not cfgKey then return end
    if not resourceMatchesActiveConfig(cfgKey, resourceName) then return end
    if ConfigBeforeAutoDetect[cfgKey] ~= 'auto_detect' then return end

    CreateThread(function()
        local timeout = 5000
        local waited = 0

        while GetResourceState(resourceName) ~= 'stopped' and waited < timeout do
            Wait(100)
            waited = waited + 100
        end

        if GetResourceState(resourceName) ~= 'stopped' then
            if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
                DEBUG(('Resource %s did not fully stop within timeout.'):format(resourceName))
            end
            return
        end

        Cfg[cfgKey] = 'none'

        if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
            DEBUG(('Supported resource stopped: %s (affects %s) — re-running auto detect.'):format(resourceName, cfgKey))
        end

        runAutoDetect()
    end)
end

if IsDuplicityVersion() then
    AddEventHandler('onResourceStart', function(resourceName)
        detectResourceStart(resourceName)
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        detectResourceStop(resourceName)
    end)
else
    AddEventHandler('onClientResourceStart', function(resourceName)
        detectResourceStart(resourceName)
    end)

    AddEventHandler('onClientResourceStop', function(resourceName)
        detectResourceStop(resourceName)
    end)
end

if CurrentResourceName == 'cd_bridge' then
    AddEventHandler('onResourceStart', function(resName)
        if resName == CurrentResourceName then return end
        if DependantResources[resName] then return end
        for _, frameworkResource in pairs(AutoDetectResources.Framework) do
            if resName == frameworkResource then return end
        end

        local cfgKey = resourceAffectsBridge(resName)
        if not cfgKey then return end

        if ConfigBeforeAutoDetect[cfgKey] == 'auto_detect' and Cfg[cfgKey] == 'none' then
            CreateThread(function()
                Wait(1000)

                if Cfg.BridgeDebug and WaitForErrorHandlingToLoad() then
                    DEBUG(('Late resource detected: %s — re-running auto detect'):format(resName))
                end

                runAutoDetect()
            end)
        end
    end)
end
