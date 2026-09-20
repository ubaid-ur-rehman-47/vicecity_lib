--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

function GetNativeFramework()
    return CBUX.FrameworkObject
end

function ExecuteForFramework(handlers)
    if not CBUX.Ready then
        CBUX.Utils.Warn("Bridge not ready for framework execution")
        return nil
    end
    
    local frameworkHandler = handlers[CBUX.Framework]
    if frameworkHandler then
        return frameworkHandler(CBUX.FrameworkObject)
    end
    
    if handlers.any then
        return handlers.any(CBUX.FrameworkObject, CBUX.Framework)
    end
    
    if handlers.default then
        return handlers.default(CBUX.FrameworkObject, CBUX.Framework)
    end
    
    return nil
end

function IsFramework(frameworkName)
    return CBUX.Framework == frameworkName
end

function IsESX()
    return CBUX.Framework == "esx"
end

function IsQBCore()
    return CBUX.Framework == "qbcore"
end

function IsQBox()
    return CBUX.Framework == "qbox"
end

function GetClientInfo()
    local info = {}
    info.framework = CBUX.Framework
    info.inventory = CBUX.Inventory
    info.hasOxLib = CBUX.HasOxLib
    info.playerLoaded = exports["CubX-Bridge"]:IsPlayerLoaded()
    return info
end

exports("GetNativeFramework", GetNativeFramework)
exports("ExecuteForFramework", ExecuteForFramework)
exports("IsFramework", IsFramework)
exports("IsESX", IsESX)
exports("IsQBCore", IsQBCore)
exports("IsQBox", IsQBox)
exports("GetClientInfo", GetClientInfo)