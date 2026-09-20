local function emit(name, source, ...)
    TriggerEvent('vicecity:phone:' .. name, source, ...)
end

AddEventHandler('phone:opened', function(source, payload)
    emit('opened', source, payload)
end)

AddEventHandler('phone:closed', function(source, payload)
    emit('closed', source, payload)
end)

AddEventHandler('qs-smartphone:marketplace:dutyChanged', function(accountId, jobName, source)
    emit('dutyChanged', source, accountId, jobName)
end)

RegisterNetEvent('vicecity:phone:sendNotification', function(data)
    local source = source
    ViceCity.Phone.SendNotification(source, data)
end)

RegisterNetEvent('vicecity:phone:createBill', function(data)
    local source = source
    ViceCity.Phone.CreateBill(source, data)
end)

RegisterNetEvent('vicecity:phone:sendMail', function(subject, body)
    local source = source
    ViceCity.Phone.SendMail(source, subject, body)
end)
