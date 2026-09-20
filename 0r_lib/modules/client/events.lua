-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- ESX: player loaded
RegisterNetEvent("esx:playerLoaded")
AddEventHandler("esx:playerLoaded", function()
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- QBCore: player loaded
RegisterNetEvent("QBCore:Client:OnPlayerLoaded")
AddEventHandler("QBCore:Client:OnPlayerLoaded", function()
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- ESX: job updated
RegisterNetEvent("esx:setJob")
AddEventHandler("esx:setJob", function(job)
    Resmon.Lib.PlayerData.job = job
    TriggerServerEvent("0R:Core:SetPlayerJob", job)
end)

-- QBCore: job updated
RegisterNetEvent("QBCore:Client:OnJobUpdate")
AddEventHandler("QBCore:Client:OnJobUpdate", function(job)
    Resmon.Lib.PlayerData.job = job
    TriggerServerEvent("0R:Core:SetPlayerJob", job)
end)

-- QB spawn UI opened (registers + handles in one call)
RegisterNetEvent("qb-spawn:client:openUI", function()
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- Resource started
AddEventHandler("onResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    TriggerServerEvent("0R:Core:NewPlayerJoined")
end)

-- Sync player data sent from server
RegisterNetEvent("0R:Core:SetPlayerData")
AddEventHandler("0R:Core:SetPlayerData", function(data)
    Resmon.Lib.PlayerData = data
end)

-- Resolve a pending server callback
RegisterNetEvent("0R:Core:ServerCallback")
AddEventHandler("0R:Core:ServerCallback", function(requestId, ...)
    local cb = Resmon.Lib.ServerCallbacks[requestId]
    cb(...)
    Resmon.Lib.ServerCallbacks[requestId] = nil
end)