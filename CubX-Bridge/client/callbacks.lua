--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local pendingCallbacks = {}
local clientCallbacks = {}
local currentId = 0

function GenerateCallbackId()
    currentId = currentId + 1
    return currentId
end

function TriggerCallback(name, cb, ...)
    if not CBUX.Ready then
        CBUX.Utils.Warn("TriggerCallback: Bridge not ready")
        if cb then
            cb(nil)
        end
        return
    end

    if CBUX.Modules.Framework and CBUX.Modules.Framework.TriggerCallback then
        CBUX.Modules.Framework.TriggerCallback(name, cb, ...)
        return
    end

    local id = CBUX.Utils.GenerateId()
    pendingCallbacks[id] = cb

    TriggerServerEvent(Config.EventPrefix .. ":callback:" .. name, id, ...)

    SetTimeout(Config.CallbackTimeout, function()
        if pendingCallbacks[id] then
            CBUX.Utils.Warn("Callback timeout:", name)
            local callback = pendingCallbacks[id]
            callback(nil)
            pendingCallbacks[id] = nil
        end
    end)
end

function AwaitCallback(name, ...)
    if not CBUX.Ready then
        CBUX.Utils.Warn("AwaitCallback: Bridge not ready")
        return nil
    end

    local p = CBUX.Utils.CreatePromise()
    TriggerCallback(name, function(result)
        p.resolve(p, result)
    end, ...)

    return p.await(p, Config.CallbackTimeout)
end

function RegisterClientCallback(name, cb)
    clientCallbacks[name] = cb
    CBUX.Utils.Debug("Client callback registered:", name)
end

RegisterNetEvent(Config.EventPrefix .. ":callback:response", function(id, result)
    if pendingCallbacks[id] then
        pendingCallbacks[id](result)
        pendingCallbacks[id] = nil
    end
end)

RegisterNetEvent(Config.EventPrefix .. ":clientCallback:trigger", function(id, name, ...)
    local cb = clientCallbacks[name]
    if cb then
        local result = cb(...)
        TriggerServerEvent(Config.EventPrefix .. ":clientCallback:response", id, result)
    else
        CBUX.Utils.Warn("Client callback not found:", name)
        TriggerServerEvent(Config.EventPrefix .. ":clientCallback:response", id, nil)
    end
end)

function IsClientCallbackRegistered(name)
    return clientCallbacks[name] ~= nil
end

function RemoveClientCallback(name)
    clientCallbacks[name] = nil
end

exports("TriggerCallback", TriggerCallback)
exports("TriggerServerCallback", TriggerCallback)
exports("AwaitCallback", AwaitCallback)
exports("RegisterClientCallback", RegisterClientCallback)
exports("IsClientCallbackRegistered", IsClientCallbackRegistered)
exports("RemoveClientCallback", RemoveClientCallback)