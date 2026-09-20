-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================

-- ============================================================
--  NEW PLAYER JOINED
-- ============================================================

RegisterNetEvent("0R:Core:NewPlayerJoined")
AddEventHandler("0R:Core:NewPlayerJoined", function()
    local playerId = source

    -- Skip if already tracked
    if Resmon.Lib.Players[playerId] then
        TriggerClientEvent("0R:Core:NewPlayerJoined", playerId, playerId)
        return
    end

    -- Guard: xPlayer helper must exist before calling it
    if type(Resmon.Lib.xPlayer) ~= "function" then
        print(("[0R:Lib] WARNING: Resmon.Lib.xPlayer is nil for player %s — framework not ready yet"):format(playerId))
        return
    end

    local xPlayer = Resmon.Lib.xPlayer(playerId)

    -- Guard: xPlayer must return a valid object
    if not xPlayer then
        print(("[0R:Lib] WARNING: xPlayer returned nil for player %s"):format(playerId))
        return
    end

    local info = xPlayer

    if Config.Framework == "ESX" then
        info.firstname = xPlayer.name
        info.lastname  = xPlayer[1] and xPlayer[1].lastname or nil
        info.phone     = nil
    else
        info.firstname = xPlayer.PlayerData.charinfo.firstname
        info.lastname  = xPlayer.PlayerData.charinfo.lastname
        info.phone     = xPlayer.PlayerData.charinfo.phone
    end

    Resmon.Lib.Players[playerId] = info

    TriggerClientEvent("0R:Core:NewPlayerJoined", playerId, playerId)
end)


-- ============================================================
--  PLAYER DATA — INTERNAL CLEANUP
-- ============================================================

RegisterNetEvent("0R:Core:PlayerDropped")
AddEventHandler("0R:Core:PlayerDropped", function(playerId)
    Resmon.Lib.Players[playerId] = nil
end)


-- ============================================================
--  SET JOB
-- ============================================================

RegisterNetEvent("0R:Core:Server:setJob")
AddEventHandler("0R:Core:Server:setJob", function(job)
    local playerId = source

    if Resmon.Lib.Players[playerId] then
        Resmon.Lib.Players[playerId].job = job
    end
end)


-- ============================================================
--  NATIVE PLAYER DROPPED
-- ============================================================

AddEventHandler("playerDropped", function(reason)
    local playerId = source
    TriggerEvent("0R:Core:PlayerDropped", playerId)
    TriggerClientEvent("0R:Core:PlayerDropped", playerId, playerId, reason)
end)