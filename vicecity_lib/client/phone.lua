local function emit(name, ...)
    TriggerEvent('vicecity:phone:' .. name, ...)
end

AddEventHandler('phone:opened', function(payload)
    emit('opened', payload)
end)

AddEventHandler('phone:closed', function(payload)
    emit('closed', payload)
end)

AddEventHandler('phone:pushNotification', function(data)
    emit('notificationReceived', data)
end)

AddEventHandler('phone:notification', function(message, notificationType)
    emit('notificationReceived', { message = message, type = notificationType })
end)

AddEventHandler('phone:usable:open', function()
    emit('usableOpened')
end)

AddEventHandler('phone:incomingCall', function(callData)
    emit('incomingCall', callData)
end)

AddEventHandler('phone:callState', function(session)
    emit('callState', session)
end)

AddEventHandler('phone:device:phoneChanged', function(phone)
    emit('numberChanged', phone)
end)

AddEventHandler('phone:dynamicIsland:action', function(islandId, actionId)
    emit('dynamicIslandAction', islandId, actionId)
end)
