NUI_status = false

-- Force close all codsesign NUI window's.
TriggerEvent('chat:addSuggestion', '/closenui', Locale('command_list_closenui'))
RegisterCommand('closenui', function()
    TriggerEvent('cd_bridge:CloseAllNUI')
end, false)

-- Enables NUI focus.
function EnableNuiFocus()
    SetNuiFocus(true, true)
    SetHudVisibility(false)
    NUI_status = true
end

-- Enables NUI focus and allows key presses.
function EnableNuiFocus_2()
    SetHudVisibility(false)
    NUI_status = true

    CreateThread(function()
        SetUserRadioControlEnabled(false)

        local disabled_keys = {1,2,21,24,25,47,58,75,106,140,141,142,143,245,257,263,264}

        while NUI_status do
            Wait(5)
            SetNuiFocus(true, true)
            SetNuiFocusKeepInput(true)

            for _, key in ipairs(disabled_keys) do
                DisableControlAction(0, key, true)
            end

            SetPlayerCanDoDriveBy(PlayerId(), false)
            HudWeaponWheelIgnoreSelection()
        end

        -- Once NUI_status is false, disable everything
        SetNuiFocus(false, false)
        SetNuiFocusKeepInput(false)
        SetUserRadioControlEnabled(true)
        SetPlayerCanDoDriveBy(PlayerId(), true)

        local count = 0
        local extra_keys = {177, 200, 202, 322}
        while count < 100 do
            Wait(0)
            count = count + 1
            for _, key in ipairs(extra_keys) do
                DisableControlAction(0, key, true)
            end
        end
    end)
end

-- Disables NUI focus.
function DisableNuiFocus(skipHudVisibility) -- skipHudVisibility = if this is true dont re-open the hud, its being force closed and kept closed for a reason.
    SetNuiFocus(false, false)
    if not skipHudVisibility then
        SetHudVisibility(true)
    end
    NUI_status = false
end

-- Plays an animation on the player ped.
local InAnimation = false
function PlayAnimation(animDict, animName, duration, loop)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    duration = duration or -1

    RequestAnimDict(animDict)
    local timeout = GetGameTimer() + 5000
    while not HasAnimDictLoaded(animDict) and GetGameTimer() < timeout do
        Wait(0)
    end

    if not HasAnimDictLoaded(animDict) then
        ERROR('2358', '[PlayAnimation] Timed out waiting for anim dict '..tostring(animDict)..' to load')
        return
    end

    TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, 49, 0.0, false, false, false)

    if loop then
        CreateThread(function()
            if InAnimation then return end
            InAnimation = true

            while InAnimation do
                Wait(100)

                if not DoesEntityExist(ped) then
                    break
                end

                if not IsEntityPlayingAnim(ped, animDict, animName, 3) and InAnimation then
                    TaskPlayAnim(ped, animDict, animName, 1.0, -1.0, duration, 49, 0.0, false, false, false)
                end
            end
        end)
    end

    if duration and duration > 0 and not loop then
        CreateThread(function()
            Wait(duration + 100)
            RemoveAnimDict(animDict)
        end)
    end
end

-- Stops the current animation.
function StopAnimation(anim_dict, anim_name)
    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    InAnimation = false

    if anim_dict and anim_name then
        StopAnimTask(ped, anim_dict, anim_name, 2.0)
    else
        ClearPedTasks(ped)
    end
end

-- Returns the closest player.
function GetClosestPlayer(maxDistance, returnData)
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)

    local closestPlayer
    local closestDistSq = maxDistance * maxDistance

    returnData = returnData or 'ped'

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local ped = GetPlayerPed(playerId)

            if ped ~= 0 then
                local distSq = #(myCoords - GetEntityCoords(ped))^2

                if distSq < closestDistSq then
                    closestDistSq = distSq
                    if returnData == 'serverid' then
                        closestPlayer = GetPlayerServerId(playerId)
                    elseif returnData == 'ped' then
                        closestPlayer = ped
                    end
                end
            end
        end
    end

    return closestPlayer
end

-- Returns all players within a certain distance.
function GetClosestPlayers(maxDistance, returnData, includeSelf)
    if not returnData then
        ERROR('3942', '[GetClosestPlayers] returnData parameter is required')
        return
    end

    local players = {}
    local myPed = PlayerPedId()
    local myCoords = GetEntityCoords(myPed)
    local maxDistSq = maxDistance * maxDistance

    for _, playerId in pairs(GetActivePlayers()) do
        if includeSelf or playerId ~= PlayerId() then

            local ped = GetPlayerPed(playerId)
            if ped ~= 0 then
                local coords = GetEntityCoords(ped)
                local distSq = #(myCoords - coords)^2

                if distSq <= maxDistSq then
                    if returnData == 'serverid' then
                        players[#players + 1] = GetPlayerServerId(playerId)
                    elseif returnData == 'ped' then
                        players[#players + 1] = ped
                    end
                end
            end
        end
    end

    return players
end

-- Gets the key label for a register keymapping command or a single key ('E').
local specialKeyCodes = { ['b_100']='LMB',['b_101']='RMB',['b_102']='MMB',['b_103']='Mouse.ExtraBtn1',['b_104']='Mouse.ExtraBtn2',['b_105']='Mouse.ExtraBtn3',['b_106']='Mouse.ExtraBtn4',['b_107']='Mouse.ExtraBtn5',['b_108']='Mouse.ExtraBtn6',['b_109']='Mouse.ExtraBtn7',['b_110']='Mouse.ExtraBtn8',['b_115']='MouseWheel.Up',['b_116']='MouseWheel.Down',['b_130']='NumSubstract',['b_131']='NumAdd',['b_134']='Num Multiplication',['b_135']='Num Enter',['b_137']='Num1',['b_138']='Num2',['b_139']='Num3',['b_140']='Num4',['b_141']='Num5',['b_142']='Num6',['b_143']='Num7',['b_144']='Num8',['b_145']='Num9',['b_170']='F1',['b_171']='F2',['b_172']='F3',['b_173']='F4',['b_174']='F5',['b_175']='F6',['b_176']='F7',['b_177']='F8',['b_178']='F9',['b_179']='F10',['b_180']='F11',['b_181']='F12',['b_182']='F13',['b_183']='F14',['b_184']='F15',['b_185']='F16',['b_186']='F17',['b_187']='F18',['b_188']='F19',['b_189']='F20',['b_190']='F21',['b_191']='F22',['b_192']='F23',['b_193']='F24',['b_194']='Arrow Up',['b_195']='Arrow Down',['b_196']='Arrow Left',['b_197']='Arrow Right',['b_198']='Delete',['b_199']='Escape',['b_200']='Insert',['b_201']='End',['b_210']='Delete',['b_211']='Insert',['b_212']='End',['b_1000']='Shift',['b_1002']='Tab',['b_1003']='Enter',['b_1004']='Backspace',['b_1009']='PageUp',['b_1008']='Home',['b_1010']='PageDown',['b_1012']='CapsLock',['b_1013']='Control',['b_1014']='Right Control',['b_1015']='Alt',['b_1055']='Home',['b_1056']='PageUp',['b_2000']='Space' }
function GetKeyMappingKeyLabel(input)
    if not input or input == '' then return nil end

    if #input == 1 then
        return input:upper()
    end

    local key = GetControlInstructionalButton(0, GetHashKey(input) | 0x80000000, true)

    if not key or key == '' then return nil end

    if key:find('t_') then
        local label = key:gsub('t_', '')
        return label ~= '' and label:upper() or nil
    end

    return specialKeyCodes[key] or nil
end

-- Loads a model into memory.
function LoadModel(model_hash)
    if not IsModelInCdimage(model_hash) or not IsModelValid(model_hash) then
        Notif(3, 'invalid_model', model_hash)
        return false
    end

    local timeout = 10000
    local start = GetGameTimer()
    while not HasModelLoaded(model_hash) and (GetGameTimer() - start) < timeout do
        RequestModel(model_hash)
        Wait(10)
    end

    if not HasModelLoaded(model_hash) then
        Notif(3, 'loading_model_failed', model_hash)
        return false
    else
        return true
    end
end

-- Ensures network control of an entity.
function EnsureNetworkControl(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end

    local timeoutMs = 2000
    local start = GetGameTimer()

    SetEntityAsMissionEntity(entity, true, true)

    local netId = NetworkGetNetworkIdFromEntity(entity)
    if not netId or netId == 0 then
        return false
    end

    SetNetworkIdExistsOnAllMachines(netId, true)
    SetNetworkIdCanMigrate(netId, true)

    while not NetworkHasControlOfEntity(entity) and (GetGameTimer() - start) < timeoutMs do
        NetworkRequestControlOfEntity(entity)
        NetworkRequestControlOfNetworkId(netId)
        Wait(10)
    end
    return NetworkHasControlOfEntity(entity)
end

-- Ensures collision is loaded for an entity.
function RequestEntityCollision(entity, coords)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return false
    end

    if coords then
        coords = vector3(coords.x, coords.y, coords.z)
    end

    local timeoutMs = 2000
    local start = GetGameTimer()
    coords = coords or GetEntityCoords(entity)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    SetEntityCollision(entity, true, true)

    while not HasCollisionLoadedAroundEntity(entity) and (GetGameTimer() - start) < timeoutMs do
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        Wait(10)
    end
    return HasCollisionLoadedAroundEntity(entity)
end

-- Draws 3D text.
function Draw3DText(coords, text)
    local onScreen, sx, sy = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(sx, sy)
end

-- Fade out.
function FadeOut(duration)
    duration = duration or 500

    if not IsScreenFadedOut() and not IsScreenFadingOut() then
        DoScreenFadeOut(duration)

        while not IsScreenFadedOut() do
            Wait(0)
        end
    end
end

-- Fade in.
function FadeIn(duration)
    duration = duration or 500

    if not IsScreenFadedIn() and not IsScreenFadingIn() then
        DoScreenFadeIn(duration)

        while not IsScreenFadedIn() do
            Wait(0)
        end
    end
end

-- Fades out, holds, then fades in.
function ScreenFade(outDuration, holdDuration, inDuration)
    FadeOut(outDuration or 500)

    if holdDuration and holdDuration > 0 then
        Wait(holdDuration)
    end

    FadeIn(inDuration or 500)
end

-- Teleports an entity to given coords.
function TeleportEntity(entity, coords, heading, opts)
    if not DoesEntityExist(entity) then return false end

    opts = opts or {}
    local freeze = opts.freeze or false
    local fade = opts.fade ~= false
    local keepVehicle = opts.keepVehicle ~= false
    local timeoutMs = opts.timeout or 5000

    local x, y, z = coords.x, coords.y, coords.z
    heading = heading or coords.h or coords.w

    local target = entity
    if keepVehicle and IsEntityAPed(entity) then
        local veh = GetVehiclePedIsIn(entity, false)
        if veh ~= 0 then
            target = veh
        end
    end

    if freeze then
        FreezeEntityPosition(target, true)
    end

    if fade then
        FadeOut(500)
    end

    RequestEntityCollision(entity, coords)
    SetEntityCoords(target, x, y, z, false, false, false, true)

    if not opts.skipGroundCheck then
        local found, groundZ = GetGroundZFor_3dCoord(x, y, z + 100.0, false)
        if found then
            SetEntityCoords(target, x, y, groundZ, false, false, false, true)
        end
    end

    if heading then
        SetEntityHeading(target, heading + 0.0)
    end

    if freeze then
        Wait(100)
        FreezeEntityPosition(target, false)
    end

    if fade then
        FadeIn(1500)
    end

    return true
end

-- Enables NUI focus from the ui side.
RegisterNuiCallback('enable_nui_focus', function(data, cb)
    EnableNuiFocus()
    cb('ok')
end)

function TBL(t)
    if GetResourceState('cd_devtools') == 'started' then
        TriggerEvent('table', t)
    else
        print(json.encode(t, { indent = true }))
    end
end

-- Notification wrapper.
function Notif(action, locale_key, ...)
    if not TypeCheck(action, 'number', '3001', 'action missing from Notif function, 1st arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    if action < 1 or action > 3 then
        return ERROR('3002', 'action not valid in Notif function, 1st arg: '..tostring(action)..'. Locale Key: '..(locale_key or 'nil'))
    end

    if not TypeCheck(locale_key, 'string', '3002', 'locale_key missing from Notif function, 2nd arg. Locale Key: '..(locale_key or 'nil')) then
        return
    end

    local preferred = tostring(Cfg.Language):upper()

    local function getFromOneTable(tbl, langKey)
        if not tbl then return nil end
        if tbl[langKey] and tbl[langKey][locale_key] then
            return tbl[langKey][locale_key]
        end
        return nil
    end

    local function findTemplate(langKey)
        return getFromOneTable(LocalesTable, langKey) or getFromOneTable(Locales, langKey) or getFromOneTable(BridgeLocalesTable, langKey)
    end

    local template = findTemplate(preferred)
    if not template and preferred ~= 'EN' then
        template = findTemplate('EN')
    end

    if not template then
        return ERROR('3003', 'locale not found in any locale table: '..tostring(locale_key)..' (lang tried: '..preferred..' -> EN)')
    end

    local message = template

    if select('#', ...) > 0 then
        local ok, formatted = pcall(string.format, template, ...)
        if not ok then
            return ERROR('3004', 'Format failed for key: ' .. tostring(locale_key))
        end
        message = formatted
    end

    local ok, err = pcall(Notification, action, message)
    if not ok then
        return ERROR('3005', 'Notification failed: ' .. tostring(err))
    end
end

-- Get players mugshot
function GetPedHeadshot(transparent)
    local player_ped = PlayerPedId()
    local handle

    local timeout = GetGameTimer() + 1000

    if transparent then
        handle = RegisterPedheadshotTransparent(player_ped)
    else
        handle = RegisterPedheadshot(player_ped)
    end

    while not IsPedheadshotReady(handle) or not IsPedheadshotValid(handle) do
        local game_timer = GetGameTimer()

        if game_timer > timeout then

            if transparent then
                return GetPedheadshot(false)
            else
                UnregisterPedheadshot(handle)
                return nil
            end


        end

        Wait(0)
    end

    local txd = GetPedheadshotTxdString(handle)

    UnregisterPedheadshot(handle)

    return txd;
end