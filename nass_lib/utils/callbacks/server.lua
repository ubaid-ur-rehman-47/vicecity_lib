local serverCallbacks = {}
local clientRequests = {}
local RequestId = 0

function nass.createCallback(eventName, callback)
    serverCallbacks[eventName] = callback
end

RegisterNetEvent("nass:triggerServerCallback", function(eventName, requestId, invoker, ...)
    if not serverCallbacks[eventName] then
        return print(("[^1ERROR^7] Server Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7"):format(eventName, invoker))
    end

    local source = source

    serverCallbacks[eventName](source, function(...)
        TriggerClientEvent("nass:serverCallback", source, requestId, invoker, ...)
    end, ...)
end)

function nass.createClientCallback(player, eventName, callback, ...)
    clientRequests[RequestId] = callback

    TriggerClientEvent("nass:triggerClientCallback", player, eventName, RequestId, GetInvokingResource() or "unknown", ...)

    RequestId = RequestId + 1
end

RegisterNetEvent("nass:clientCallback", function(requestId, invoker, ...)
    if not clientRequests[requestId] then
        return print(("[^1ERROR^7] Client Callback with requestId ^5%s^7 Was Called by ^5%s^7 but does not exist."):format(requestId, invoker))
    end

    clientRequests[requestId](...)
    clientRequests[requestId] = nil
end)