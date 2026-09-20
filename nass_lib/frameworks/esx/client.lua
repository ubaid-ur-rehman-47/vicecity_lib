if GetResourceState('es_extended') ~= 'started' then return end
ESX = exports['es_extended']:getSharedObject()

nass.framework, nass.playerData, nass.playerLoaded = "esx", {}, nil

RegisterNetEvent('esx:playerLoaded', function(xPlayer)
    nass.playerData = xPlayer
    nass.playerLoaded = true
end)

AddEventHandler('esx:onPlayerSpawn', function()
    nass.playerData = ESX.GetPlayerData()
    nass.playerLoaded = true
    TriggerEvent('nass_lib:playerLoaded')
end)

RegisterNetEvent('esx:onPlayerLogout', function()
    table.wipe(nass.playerData)
    nass.playerLoaded = false
end)

RegisterNetEvent('esx:setJob', function(job)
    nass.playerData.job = job
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName or not ESX.PlayerLoaded then return end
    nass.playerData = ESX.GetPlayerData()
    nass.playerLoaded = true
end)

AddEventHandler('esx:setPlayerData', function(key, value)
    if GetInvokingResource() ~= 'es_extended' then return end
    nass.playerData[key] = value
end)

function nass.getPlayerData()
    nass.playerData = ESX.GetPlayerData()
    return nass.playerData
end

function nass.notify(msg, type, title, length)
    if GetResourceState('nass_notifications') == 'started' then
        exports["nass_notifications"]:ShowNotification(type or "alert", title or "Info", msg, length or 5000)
    else
        ESX.ShowNotification(msg)
    end
end

function nass.getJob()
    return nass.playerData.job
end

function nass.getPlayerName(full)
    local first, last = nass.playerData.firstName, nass.playerData.lastName
    if full then
        return first .." ".. last
    end
    return first, last
end

function nass.setVehicleProps(vehicle, props)
    ESX.Game.SetVehicleProperties(vehicle, props)
end

function nass.getVehicleProps(vehicle)
    return ESX.Game.GetVehicleProperties(vehicle)
end

function nass.openBossmenu(jobName, onClose, options)
    TriggerEvent("esx_society:openBossMenu", jobName, onClose, options)
end