-- Credits to es_extended
local RequestId = 0
local serverRequests = {}
local clientCallbacks = {}
local lastCallbackTimes = {}
local callbackCounts = {}
local rateLimit = 500 -- Rate limit in milliseconds
local maxRequests = 3 -- Maximum allowed requests within the rate limit period

function nass.triggerCallback(eventName, callback, ...)
    local currentTime = GetGameTimer()
    local resource = GetInvokingResource() or "unknown"

    -- Initialize the last callback time and count if not set
    if not lastCallbackTimes[resource] then
        lastCallbackTimes[resource] = {}
    end

    if not callbackCounts[resource] then
        callbackCounts[resource] = {}
    end

    if not lastCallbackTimes[resource][eventName] then
        lastCallbackTimes[resource][eventName] = 0
        callbackCounts[resource][eventName] = 0
    end

    -- Reset the callback count if the rate limit period has passed
    if currentTime - lastCallbackTimes[resource][eventName] >= rateLimit then
        callbackCounts[resource][eventName] = 0
    end

    -- Increment the callback count
    callbackCounts[resource][eventName] = callbackCounts[resource][eventName] + 1

    -- Check if the callback has been called more than the max allowed times within the rate limit period
    if callbackCounts[resource][eventName] > maxRequests then
        return print(("[^1ERROR^7] Rate limit exceeded for ^5%s^7, resource: ^5%s^7. ^5%s^7 calls within %d ms, This is a security feature to prevent abuse DO NOT REPORT THIS IN A TICKET."):format(eventName, resource, callbackCounts[resource][eventName], rateLimit))
    end

    -- Update the last callback time
    lastCallbackTimes[resource][eventName] = currentTime

    -- Execute the callback
    serverRequests[RequestId] = callback
    TriggerServerEvent("nass:triggerServerCallback", eventName, RequestId, resource, ...)
    RequestId = RequestId + 1
end

RegisterNetEvent("nass:serverCallback", function(requestId, invoker, ...)
    if not serverRequests[requestId] then
        return print(("[^1ERROR CODE 871^7] Server Callback was called by ^5%s^7 but does not exist."):format(invoker))
    end

    serverRequests[requestId](...)
    serverRequests[requestId] = nil
end)

function nass.createClientCallback(eventName, callback)
    clientCallbacks[eventName] = callback
end

RegisterNetEvent("nass:triggerClientCallback", function(eventName, requestId, invoker, ...)
    if not clientCallbacks[eventName] then
        return print(("[^1ERROR CODE 872^7] Server Callback was called by ^5%s^7 but does not exist."):format(invoker))
    end

    clientCallbacks[eventName](function(...)
        TriggerServerEvent("nass:clientCallback", requestId, invoker, ...)
    end, ...)
end)