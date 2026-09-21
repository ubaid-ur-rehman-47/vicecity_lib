if not lib then return end

-- ─────────────────────────────────────────────────────────────
--  ox_inventory · playerinfo module
--  Detects bank balance from active framework and pushes via NUI
-- ─────────────────────────────────────────────────────────────

local PlayerInfo = {}
local lastBank = -1
local lastId = -1

-- Latest registered ped-headshot handle. Kept alive so the transparent
-- texture stays available to NUI for the duration of the session; we
-- unregister the previous one only when re-registering, to avoid the
-- in-game texture being reclaimed mid-use.
local headshotHandle = nil
local headshotTxd = nil

local function safeCall(fn)
    local ok, result = pcall(fn)
    if ok then return result end
    return nil
end

---@return number
local function detectBank()
    -- ESX Legacy / es_extended
    if GetResourceState('es_extended') == 'started' then
        local ESX = safeCall(function() return exports['es_extended']:getSharedObject() end)
        if ESX then
            local pd = safeCall(function() return ESX.GetPlayerData() end)
            if pd and pd.accounts then
                for _, acc in ipairs(pd.accounts) do
                    if acc.name == 'bank' then return tonumber(acc.money) or 0 end
                end
            end
        end
    end

    -- qbx_core (Qbox)
    if GetResourceState('qbx_core') == 'started' then
        local pd = safeCall(function() return exports.qbx_core:GetPlayerData() end)
        if pd and pd.money and pd.money.bank ~= nil then
            return tonumber(pd.money.bank) or 0
        end
    end

    -- qb-core
    if GetResourceState('qb-core') == 'started' then
        local QBCore = safeCall(function() return exports['qb-core']:GetCoreObject() end)
        if QBCore then
            local pd = safeCall(function() return QBCore.Functions.GetPlayerData() end)
            if pd and pd.money and pd.money.bank ~= nil then
                return tonumber(pd.money.bank) or 0
            end
        end
    end

    -- esx_addonaccount (legacy)
    if GetResourceState('esx_addonaccount') == 'started' then
        local ESX = safeCall(function() return exports['es_extended']:getSharedObject() end)
        if ESX then
            local pd = safeCall(function() return ESX.GetPlayerData() end)
            if pd and pd.accounts then
                for _, acc in ipairs(pd.accounts) do
                    if acc.name == 'bank' then return tonumber(acc.money) or 0 end
                end
            end
        end
    end

    return 0
end

---Generates a transparent-background headshot of the local ped and
---sends its in-game texture dictionary name to the UI. The UI then
---renders it via the FiveM-special `nui-img://<txd>/<txd>` scheme.
---
---Polls for ~3s for readiness — generation is async on the engine side
---and usually completes within 500–1500 ms. Re-registers each call to
---pick up outfit/skin changes (the previous handle is released first).
function PlayerInfo.sendHeadshot()
    local ped = PlayerPedId()
    if not ped or ped == 0 then return end

    -- Release the previous handle before requesting a new one. We
    -- DON'T release the new handle on inventory close — the NUI keeps
    -- the texture URL cached and re-uses it on next open.
    if headshotHandle then
        UnregisterPedheadshot(headshotHandle)
        headshotHandle = nil
        headshotTxd = nil
    end

    local handle = RegisterPedheadshotTransparent(ped)
    if not handle or handle == 0 then return end

    CreateThread(function()
        local attempts = 0
        while not IsPedheadshotReady(handle) and attempts < 60 do
            Wait(50)
            attempts = attempts + 1
        end

        if IsPedheadshotReady(handle) and IsPedheadshotValid(handle) then
            headshotHandle = handle
            headshotTxd = GetPedheadshotTxdString(handle)
            SendNUIMessage({
                action = 'setPlayerHeadshot',
                data = { txd = headshotTxd },
            })
        else
            -- Generation failed / timed out — release the handle.
            UnregisterPedheadshot(handle)
        end
    end)
end

---Sends current player info to the UI
function PlayerInfo.send(force)
    local bank = detectBank()
    local id = GetPlayerServerId(PlayerId())

    if not force and bank == lastBank and id == lastId then return end

    lastBank = bank
    lastId = id

    SendNUIMessage({
        action = 'setPlayerInfo',
        data = { bank = bank, id = id }
    })

    -- Refresh headshot on every forced send (i.e. inventory open) so
    -- outfit / character-creator changes get picked up automatically.
    if force then
        PlayerInfo.sendHeadshot()
    end
end

-- Send when relevant data changes. These events are fired by the
-- frameworks across the network (server → client), so each one must
-- be registered with RegisterNetEvent before AddEventHandler — otherwise
-- FiveM logs "event was not safe for net" the first time it fires.
RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function() PlayerInfo.send() end)

RegisterNetEvent('esx:setPlayerData')
AddEventHandler('esx:setPlayerData', function(key) if key == 'accounts' then PlayerInfo.send() end end)

RegisterNetEvent('QBCore:Player:SetPlayerData')
AddEventHandler('QBCore:Player:SetPlayerData', function() PlayerInfo.send() end)

RegisterNetEvent('qbx_core:client:setPlayerData')
AddEventHandler('qbx_core:client:setPlayerData', function() PlayerInfo.send() end)

return PlayerInfo
