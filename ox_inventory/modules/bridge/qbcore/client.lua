--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local QBCore = exports['qb-core']:GetCoreObject()
local currentJob, currentGang

RegisterNetEvent('QBCore:Client:OnPlayerUnload', client.onLogout)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local PlayerDataQB = QBCore.Functions.GetPlayerData()
    local groups = {}

    currentJob = PlayerDataQB.job.name
    groups[currentJob] = PlayerDataQB.job.grade.level

    if PlayerDataQB.gang and PlayerDataQB.gang.name ~= 'none' then
        currentGang = PlayerDataQB.gang.name
        groups[currentGang] = PlayerDataQB.gang.grade.level
    end

    client.setPlayerData('groups', groups)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(job)
    local groups = PlayerData.groups or {}
    if currentJob then groups[currentJob] = nil end
    currentJob = job.name
    groups[job.name] = job.grade.level
    client.setPlayerData('groups', groups)
end)

RegisterNetEvent('QBCore:Client:OnGangUpdate', function(gang)
    local groups = PlayerData.groups or {}
    if currentGang then groups[currentGang] = nil end

    if gang.name ~= 'none' then
        currentGang = gang.name
        groups[gang.name] = gang.grade.level
    else
        currentGang = nil
    end

    client.setPlayerData('groups', groups)
end)

function client.getPlayerStatus()
    local playerState = LocalPlayer.state
    if playerState.hunger ~= nil then
        return {
            hunger = playerState.hunger or 100,
            thirst = playerState.thirst or 100,
        }
    end

    local metadata = QBCore.Functions.GetPlayerData().metadata
    return {
        hunger = metadata.hunger or 100,
        thirst = metadata.thirst or 100,
    }
end

function client.setPlayerStatus(values)
    local playerState = LocalPlayer.state

    for name, value in pairs(values) do
        if value > 100 or value < -100 then
            value = value * 0.0001
        end

        if playerState[name] ~= nil then
            playerState:set(name, playerState[name] + value, true)
        else
            local metadata = QBCore.Functions.GetPlayerData().metadata
            local current = metadata[name] or 100
            TriggerServerEvent('QBCore:Server:SetMetaData', name, math.max(0, math.min(100, current + value)))
        end
    end
end