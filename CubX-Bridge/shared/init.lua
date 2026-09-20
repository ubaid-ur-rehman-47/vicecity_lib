--  ____    _    _   _ _   _
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

if not CBUX then
    CBUX = {}
end

CBUX.Ready = false
CBUX.Framework = nil
CBUX.FrameworkObject = nil
CBUX.Inventory = nil
CBUX.HasOxLib = false
CBUX.Appearance = nil
CBUX.Modules = {
    Framework = nil,
    Inventory = nil,
    Appearance = nil
}

if not CBUX.RegisteredModules then
    CBUX.RegisteredModules = {
        frameworks = {},
        inventories = {},
        appearances = {}
    }
end

function CBUX.RegisterModule(category, name, module)
    if not CBUX.RegisteredModules[category] then
        if CBUX.Utils and CBUX.Utils.Error then
            CBUX.Utils.Error("Unknown module category:", category)
        end
        return
    end

    CBUX.RegisteredModules[category][name] = module

    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug(string.format("Registered %s module: %s", category, name))
    end
end

if IsDuplicityVersion() then
    CBUX.Players = {}
else
    CBUX.PlayerData = nil
end

function DetectFramework()
    if Config.Framework then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Framework override from config:", Config.Framework)
        end
        return Config.Framework
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.qbox) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected QBox framework")
        end
        return "qbox"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.qbcore) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected QB-Core framework")
        end
        return "qbcore"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.esx) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected ESX framework")
        end
        return "esx"
    end

    return nil
end

function DetectInventory()
    if Config.Inventory then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Inventory override from config:", Config.Inventory)
        end
        return Config.Inventory
    end

    -- if CBUX.Utils.IsResourceStarted(Config.ResourceNames.ox_inventory) then
    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug("Detected ox_inventory")
        return "ox_inventory"
    end

    -- end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.qs_inventory) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected qs-inventory")
        end
        return "qs-inventory"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.codem_inventory) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected codem-inventory")
        end
        return "codem-inventory"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.qb_inventory) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected qb-inventory")
        end
        return "qb-inventory"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.esx_inventory) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected esx_inventory")
        end
        return "esx_inventory"
    end

    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug("No external inventory detected, using native")
    end
    -- return "native"
end

function GetFrameworkModule(frameworkName)
    local module = CBUX.RegisteredModules.frameworks[frameworkName]
    if not module then
        if CBUX.Utils and CBUX.Utils.Error then
            CBUX.Utils.Error("Framework module not registered:", frameworkName)
        end
        return nil
    end

    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug("Selected framework module:", frameworkName)
    end
    return module
end

function GetInventoryModule(inventoryName)
    if inventoryName == "native" then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Using native framework inventory")
        end
        return nil
    end

    local module = CBUX.RegisteredModules.inventories[inventoryName]
    if not module then
        if CBUX.Utils and CBUX.Utils.Error then
            CBUX.Utils.Error("Inventory module not registered:", inventoryName)
        end
        return nil
    end

    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug("Selected inventory module:", inventoryName)
    end
    return module
end

function DetectAppearance()
    if Config.Appearance then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Appearance override from config:", Config.Appearance)
        end
        return Config.Appearance
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.illenium_appearance) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected illenium-appearance")
        end
        return "illenium-appearance"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.qb_clothing) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected qb-clothing")
        end
        return "qb-clothing"
    end

    if CBUX.Utils.IsResourceStarted(Config.ResourceNames.esx_skin) then
        if CBUX.Utils and CBUX.Utils.Debug then
            CBUX.Utils.Debug("Detected esx_skin")
        end
        return "esx_skin"
    end

    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug("No appearance system detected")
    end
    return nil
end

function GetAppearanceModule(appearanceName)
    if not appearanceName then return nil end

    local module = CBUX.RegisteredModules.appearances[appearanceName]
    if not module then
        if CBUX.Utils and CBUX.Utils.Error then
            CBUX.Utils.Error("Appearance module not registered:", appearanceName)
        end
        return nil
    end

    if CBUX.Utils and CBUX.Utils.Debug then
        CBUX.Utils.Debug("Selected appearance module:", appearanceName)
    end
    return module
end

function InitializeBridge()
    CBUX.Framework = DetectFramework()
    if not CBUX.Framework then
        CBUX.Utils.Error(Config.Translate("no_framework"))
        return false
    end

    CBUX.Utils.Print(Config.Translate("framework_detected", CBUX.Framework))

    CBUX.Inventory = DetectInventory()
    CBUX.Utils.Print(Config.Translate("inventory_detected", CBUX.Inventory))

    CBUX.Appearance = DetectAppearance()
    if CBUX.Appearance then
        CBUX.Utils.Print(Config.Translate("appearance_detected", CBUX.Appearance))
    end

    CBUX.HasOxLib = CBUX.Utils.IsResourceStarted(Config.ResourceNames.ox_lib)
    if CBUX.HasOxLib then
        CBUX.Utils.Debug("ox_lib detected, will use for UI features")
    end

    CBUX.Modules.Framework = GetFrameworkModule(CBUX.Framework)
    if not CBUX.Modules.Framework then
        CBUX.Utils.Error("Failed to load framework module!")
        return false
    end

    if CBUX.Inventory ~= "native" then
        CBUX.Modules.Inventory = GetInventoryModule(CBUX.Inventory)
    end

    if CBUX.Appearance then
        CBUX.Modules.Appearance = GetAppearanceModule(CBUX.Appearance)
    end

    CBUX.Ready = true
    CBUX.Utils.Print(Config.Translate("bridge_ready"))

    TriggerEvent(Config.EventPrefix .. ":ready", CBUX.Framework, CBUX.Inventory)
    return true
end

function CBUX.WaitForReady(timeout)
    timeout = timeout or 10000
    local startTime = GetGameTimer()

    while not CBUX.Ready do
        Wait(100)
        if (GetGameTimer() - startTime) > timeout then
            CBUX.Utils.Error("Bridge initialization timeout!")
            return false
        end
    end
    return true
end

exports("IsReady", function()
    return CBUX.Ready
end)

exports("GetFramework", function()
    return CBUX.Framework
end)

exports("GetInventorySystem", function()
    return CBUX.Inventory
end)

exports("HasOxLib", function()
    return CBUX.HasOxLib
end)

exports("GetAppearanceSystem", function()
    return CBUX.Appearance
end)

exports("WaitForReady", function(timeout)
    return CBUX.WaitForReady(timeout)
end)

exports("Translate", function(key, ...)
    return Config.Translate(key, ...)
end)

CreateThread(function()
    Wait(500)
    if not InitializeBridge() then
        CBUX.Utils.Error("Bridge initialization failed!")
        return
    end

    if CBUX.Modules.Framework and CBUX.Modules.Framework.Initialize then
        CBUX.Modules.Framework.Initialize()
    end

    if CBUX.Modules.Inventory and CBUX.Modules.Inventory.Initialize then
        CBUX.Modules.Inventory.Initialize()
    end

    if CBUX.Modules.Appearance and CBUX.Modules.Appearance.Initialize then
        CBUX.Modules.Appearance.Initialize()
    end
end)
