-- =====================================================
--  decrypted by https://discord.gg/6NCbAv2VNK 𝐀𝐤 𝐋𝐞𝐚𝐤𝐬 
--      Cleaned By Said Ak Using Claude Sonnet 4.6
-- =====================================================


ResmonFramework = nil

Resmon.Lib.PlayerData        = {}
Resmon.Lib.CurrentRequestId  = 0
Resmon.Lib.ServerCallbacks   = {}
Resmon.Lib.UI                = {}
Resmon.Lib.Callback          = {}
Resmon.Lib.PropertiesVehicle = {}
Resmon.Lib.Craft             = {}
Resmon.Lib.Apartment         = {}
Resmon.Lib.Craft_V2          = {}

-- Detect ESX
if GetResourceState(Config.CoreName.ESX) ~= "missing" then
    Config.Framework = "ESX"
    ResmonFramework  = exports[Config.CoreName.ESX].getSharedObject()
end

-- Detect QBCore
if GetResourceState(Config.CoreName.QBCore) ~= "missing" then
    Config.Framework = "QBCore"
    ResmonFramework  = exports[Config.CoreName.QBCore].GetCoreObject()
end

-- ── Framework helpers ─────────────────────────────────────────────────────────

function Resmon.Lib.GetFramework()
    return Config.Framework
end

Resmon.Lib.PlayerLoadedEvent = Config.PlayerLoadedEvents[Config.Framework]
Resmon.Lib.PlayerJobEvent    = Config.PlayerJobEvents[Config.Framework]

exports("GetFramework", function()
    return Config.Framework
end)

-- ── Utility ───────────────────────────────────────────────────────────────────

--- Replace every character in `str` that matches `pattern` with a random
--- printable ASCII character and return the result.
function Resmon.Lib.GenerateHash(str, pattern)
    local cleaned = string.gsub(str, pattern, "")
    local result  = ""
    for i = 1, string.len(cleaned) do
        result = result .. string.char(math.random(32, 126))
    end
    return result
end

--- Trim leading/trailing whitespace.
function Resmon.Lib.Trim(str)
    if not str then return nil end
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

--- Capitalise the first character of a string.
function Resmon.Lib.FirstToUpper(str)
    if not str then return nil end
    return str:gsub("^%l", string.upper)
end

--- Round `value` to `decimals` decimal places (or to nearest integer if nil).
function Resmon.Lib.Round(value, decimals)
    if not decimals then
        return math.floor(value + 0.5)
    end
    local mult = 10 ^ decimals
    return math.floor(value * mult + 0.5) / mult
end

--- Serialize a value (table or primitive) to a pretty-printed string.
function Resmon.Lib.DumpTable(value, depth)
    depth = depth or 0
    if type(value) == "table" then
        local indent = ""
        for _ = 1, depth + 1 do indent = indent .. "    " end
        local result = "{\n"
        for k, v in pairs(value) do
            if type(k) ~= "number" then k = '"' .. k .. '"' end
            for _ = 1, depth do result = result .. "    " end
            result = result .. "[" .. k .. "] = " .. Resmon.Lib.DumpTable(v, depth + 1) .. ",\n"
        end
        for _ = 1, depth do result = result .. "    " end
        return result .. "}"
    else
        return tostring(value)
    end
end

-- ── Server callbacks ──────────────────────────────────────────────────────────

--- Trigger a named server callback. `cb` is called with the response args.
function Resmon.Lib.Callback.Client(name, cb, ...)
    local requestId = Resmon.Lib.CurrentRequestId
    Resmon.Lib.ServerCallbacks[requestId] = cb
    TriggerServerEvent("0R:Core:TriggerCallback", name, requestId, ...)
    if Resmon.Lib.CurrentRequestId < 65535 then
        Resmon.Lib.CurrentRequestId = Resmon.Lib.CurrentRequestId + 1
    else
        Resmon.Lib.CurrentRequestId = 0
    end
end

-- ── Player data ───────────────────────────────────────────────────────────────

--- Returns true when the local player is fully loaded into the session.
function Resmon.Lib.IsPlayerLoaded()
    if Config.Framework == "ESX" then
        return ResmonFramework.IsPlayerLoaded()
    else
        return LocalPlayer.state.isLoggedIn
    end
end

--- Return a normalised player-data table for the local player.
--- Adds `.cash`, `.bank`, and `.job.grade_level` regardless of framework.
function Resmon.Lib.GetPlayerData()
    local data = {}

    if Config.Framework == "ESX" then
        data = ResmonFramework.GetPlayerData()
        if data then
            -- Flatten ESX accounts array into data.cash / data.bank
            if data.accounts then
                for _, account in pairs(data.accounts) do
                    if account.name == "bank" then
                        data.bank = account.money
                    elseif account.name == "money" then
                        data.cash = account.money
                    end
                end
            end
            -- Normalise grade
            if data.job then
                data.job.grade_level = data.job.grade
            end
        end
    else
        data = ResmonFramework.Functions.GetPlayerData()
        if data then
            data.identifier = data.citizenid
            if data.money then
                data.cash = data.money.cash
                data.bank = data.money.bank
            end
            if data.job and data.job.grade then
                data.job.grade_level = data.job.grade.level
            end
        end
    end

    return data or {}
end

-- ── Notifications ─────────────────────────────────────────────────────────────

RegisterNetEvent("0R:Lib:Notify")
AddEventHandler("0R:Lib:Notify", function(data)
    SendNUIMessage({ type = "showNotify", data = data })
end)

function Resmon.Lib.Notify(data)
    SendNUIMessage({ type = "showNotify", data = data })
end

function Resmon.Lib.ShowTextUI(text, icon)
    if not Config.CustomTextUI then
        SendNUIMessage({ type = "showUI", icon = icon, string = text })
    else
        Config.CustomTextUIFunc(text)
    end
end

function Resmon.Lib.HideTextUI()
    if not Config.CustomTextUI then
        SendNUIMessage({ type = "hideUI" })
    else
        Config.CustomTextUIHide()
    end
end

function Resmon.Lib.ShowNotify(msg, notifyType, duration)
    if not Config.CustomNotify then
        if Config.Framework == "ESX" then
            ResmonFramework.ShowNotification(msg, notifyType, duration)
        else
            ResmonFramework.Functions.Notify(msg, notifyType, duration)
        end
    end
end

-- ── Player helpers ────────────────────────────────────────────────────────────

--- Return a list (or map) of active players.
--- @param excludeSelf  boolean  Omit the local player from results.
--- @param returnPeds   boolean  Use player ID as key and ped as value.
--- @param returnAll    boolean  Include non-existent peds.
function Resmon.Lib.GetPlayers(excludeSelf, returnPeds, returnAll)
    local result = {}
    local selfId = PlayerId()
    for _, playerId in ipairs(GetActivePlayers()) do
        local ped = GetPlayerPed(playerId)
        if DoesEntityExist(ped) and (excludeSelf and playerId ~= selfId or not excludeSelf) then
            if returnPeds then
                result[playerId] = ped
            else
                local idx = #result + 1
                local val = (not returnAll or not ped) and playerId or ped
                result[idx] = val
            end
        end
    end
    return result
end

--- Return (playerId, distance) for the player nearest to `coords`.
--- If `coords` is nil the local ped's position is used (and the local player
--- is excluded from the search).
function Resmon.Lib.GetClosestPlayer(coords)
    local players       = Resmon.Lib.GetPlayers()
    local closestDist   = -1
    local closestPlayer = -1
    local selfPed       = PlayerPedId()
    local selfId        = PlayerId()
    local excludeSelf   = false

    if coords == nil then
        excludeSelf = true
        coords      = GetEntityCoords(selfPed)
    end

    for i = 1, #players do
        if excludeSelf and players[i] == selfId then goto continue end
        local pedCoords = GetEntityCoords(GetPlayerPed(players[i]))
        local dist      = GetDistanceBetweenCoords(pedCoords, coords.x, coords.y, coords.z, true)
        if closestDist == -1 or closestDist > dist then
            closestPlayer = players[i]
            closestDist   = dist
        end
        ::continue::
    end

    return closestPlayer, closestDist
end

-- ── Vehicle plate ─────────────────────────────────────────────────────────────

--- Return the trimmed plate text of `vehicle`, or nil if vehicle == 0.
function Resmon.Lib.GetPlate(vehicle)
    if vehicle == 0 then return end
    return Resmon.Lib.Trim(GetVehicleNumberPlateText(vehicle))
end

-- ── Vehicle properties – Get ──────────────────────────────────────────────────

--- Snapshot all visual and mechanical properties of `vehicle` into a table.
function Resmon.Lib.PropertiesVehicle.Get(vehicle)
    if not DoesEntityExist(vehicle) then return end

    local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
    local color1, color2               = GetVehicleColours(vehicle)

    -- Custom primary colour
    if GetIsVehiclePrimaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomPrimaryColour(vehicle)
        color1 = { r, g, b }
    end

    -- Custom secondary colour
    if GetIsVehicleSecondaryColourCustom(vehicle) then
        local r, g, b = GetVehicleCustomSecondaryColour(vehicle)
        color2 = { r, g, b }
    end

    -- Extras (0-12)
    local extras = {}
    for i = 0, 12 do
        if DoesExtraExist(vehicle, i) then
            extras[tostring(i)] = IsVehicleExtraTurnedOn(vehicle, i) == 1
        end
    end

    -- Livery: prefer mod-slot 48; fall back to livery slot when -1
    local livery = GetVehicleMod(vehicle, 48)
    if livery == -1 then
        local vl = GetVehicleLivery(vehicle)
        if vl ~= 0 then livery = vl end
    end

    -- Tyre health (wheels 0-3)
    local tireHealth = {}
    for i = 0, 3 do
        tireHealth[i] = GetVehicleWheelHealth(vehicle, i)
    end

    -- Tyre burst – slow (0-5)
    local tireBurstState = {}
    for i = 0, 5 do
        tireBurstState[i] = IsVehicleTyreBurst(vehicle, i, false)
    end

    -- Tyre burst – completely (0-5)
    local tireBurstCompletely = {}
    for i = 0, 5 do
        tireBurstCompletely[i] = IsVehicleTyreBurst(vehicle, i, true)
    end

    -- Window intact status (0-7)
    local windowStatus = {}
    for i = 0, 7 do
        windowStatus[i] = IsVehicleWindowIntact(vehicle, i) == 1
    end

    -- Door damage status (0-5)
    local doorStatus = {}
    for i = 0, 5 do
        doorStatus[i] = IsVehicleDoorDamaged(vehicle, i) == 1
    end

    -- Neon lights enabled (left/right/front/back)
    local neonEnabled = {
        IsVehicleNeonLightEnabled(vehicle, 0),
        IsVehicleNeonLightEnabled(vehicle, 1),
        IsVehicleNeonLightEnabled(vehicle, 2),
        IsVehicleNeonLightEnabled(vehicle, 3),
    }

    -- Assemble props
    local props = {}
    props.model              = GetEntityModel(vehicle)
    props.plate              = Resmon.Lib.GetPlate(vehicle)
    props.plateIndex         = GetVehicleNumberPlateTextIndex(vehicle)
    props.bodyHealth         = Resmon.Lib.Round(GetVehicleBodyHealth(vehicle),        0.1)
    props.engineHealth       = Resmon.Lib.Round(GetVehicleEngineHealth(vehicle),      0.1)
    props.tankHealth         = Resmon.Lib.Round(GetVehiclePetrolTankHealth(vehicle),  0.1)
    props.fuelLevel          = Resmon.Lib.Round(GetVehicleFuelLevel(vehicle),         0.1)
    props.dirtLevel          = Resmon.Lib.Round(GetVehicleDirtLevel(vehicle),         0.1)
    props.oilLevel           = Resmon.Lib.Round(GetVehicleOilLevel(vehicle),          0.1)
    props.color1             = color1
    props.color2             = color2
    props.pearlescentColor   = pearlescentColor
    props.dashboardColor     = GetVehicleDashboardColour(vehicle)
    props.wheelColor         = wheelColor
    props.wheels             = GetVehicleWheelType(vehicle)
    props.wheelSize          = GetVehicleWheelSize(vehicle)
    props.wheelWidth         = GetVehicleWheelWidth(vehicle)
    props.tireHealth         = tireHealth
    props.tireBurstState     = tireBurstState
    props.tireBurstCompletely = tireBurstCompletely
    props.windowTint         = GetVehicleWindowTint(vehicle)
    props.windowStatus       = windowStatus
    props.doorStatus         = doorStatus
    props.xenonColor         = GetVehicleXenonLightsColour(vehicle)
    props.neonEnabled        = neonEnabled
    props.neonColor          = table.pack(GetVehicleNeonLightsColour(vehicle))
    props.headlightColor     = GetVehicleHeadlightsColour(vehicle)
    props.interiorColor      = GetVehicleInteriorColour(vehicle)
    props.extras             = extras
    props.tyreSmokeColor     = table.pack(GetVehicleTyreSmokeColor(vehicle))
    props.modSpoilers        = GetVehicleMod(vehicle, 0)
    props.modFrontBumper     = GetVehicleMod(vehicle, 1)
    props.modRearBumper      = GetVehicleMod(vehicle, 2)
    props.modSideSkirt       = GetVehicleMod(vehicle, 3)
    props.modExhaust         = GetVehicleMod(vehicle, 4)
    props.modFrame           = GetVehicleMod(vehicle, 5)
    props.modGrille          = GetVehicleMod(vehicle, 6)
    props.modHood            = GetVehicleMod(vehicle, 7)
    props.modFender          = GetVehicleMod(vehicle, 8)
    props.modRightFender     = GetVehicleMod(vehicle, 9)
    props.modRoof            = GetVehicleMod(vehicle, 10)
    props.modEngine          = GetVehicleMod(vehicle, 11)
    props.modBrakes          = GetVehicleMod(vehicle, 12)
    props.modTransmission    = GetVehicleMod(vehicle, 13)
    props.modHorns           = GetVehicleMod(vehicle, 14)
    props.modSuspension      = GetVehicleMod(vehicle, 15)
    props.modArmor           = GetVehicleMod(vehicle, 16)
    props.modKit17           = GetVehicleMod(vehicle, 17)
    props.modTurbo           = IsToggleModOn(vehicle, 18)
    props.modKit19           = GetVehicleMod(vehicle, 19)
    props.modSmokeEnabled    = IsToggleModOn(vehicle, 20)
    props.modKit21           = GetVehicleMod(vehicle, 21)
    props.modXenon           = IsToggleModOn(vehicle, 22)
    props.modFrontWheels     = GetVehicleMod(vehicle, 23)
    props.modBackWheels      = GetVehicleMod(vehicle, 24)
    props.modCustomTiresF    = GetVehicleModVariation(vehicle, 23)
    props.modCustomTiresR    = GetVehicleModVariation(vehicle, 24)
    props.modPlateHolder     = GetVehicleMod(vehicle, 25)
    props.modVanityPlate     = GetVehicleMod(vehicle, 26)
    props.modTrimA           = GetVehicleMod(vehicle, 27)
    props.modOrnaments       = GetVehicleMod(vehicle, 28)
    props.modDashboard       = GetVehicleMod(vehicle, 29)
    props.modDial            = GetVehicleMod(vehicle, 30)
    props.modDoorSpeaker     = GetVehicleMod(vehicle, 31)
    props.modSeats           = GetVehicleMod(vehicle, 32)
    props.modSteeringWheel   = GetVehicleMod(vehicle, 33)
    props.modShifterLeavers  = GetVehicleMod(vehicle, 34)
    props.modAPlate          = GetVehicleMod(vehicle, 35)
    props.modSpeakers        = GetVehicleMod(vehicle, 36)
    props.modTrunk           = GetVehicleMod(vehicle, 37)
    props.modHydrolic        = GetVehicleMod(vehicle, 38)
    props.modEngineBlock     = GetVehicleMod(vehicle, 39)
    props.modAirFilter       = GetVehicleMod(vehicle, 40)
    props.modStruts          = GetVehicleMod(vehicle, 41)
    props.modArchCover       = GetVehicleMod(vehicle, 42)
    props.modAerials         = GetVehicleMod(vehicle, 43)
    props.modTrimB           = GetVehicleMod(vehicle, 44)
    props.modTank            = GetVehicleMod(vehicle, 45)
    props.modWindows         = GetVehicleMod(vehicle, 46)
    props.modKit47           = GetVehicleMod(vehicle, 47)
    props.modLivery          = livery
    props.modKit49           = GetVehicleMod(vehicle, 49)
    props.liveryRoof         = GetVehicleRoofLivery(vehicle)

    return props
end

-- ── Vehicle properties – Set ──────────────────────────────────────────────────

--- Apply a props table (as returned by Get) to `vehicle`.
function Resmon.Lib.PropertiesVehicle.Set(vehicle, props)
    if not DoesEntityExist(vehicle) then return end

    -- Extras
    if props.extras then
        for extraId, enabled in pairs(props.extras) do
            SetVehicleExtra(vehicle, tonumber(extraId), enabled and 0 or 1)
        end
    end

    local currentColor1, currentColor2 = GetVehicleColours(vehicle)
    local currentPearl,  currentWheel  = GetVehicleExtraColours(vehicle)

    SetVehicleModKit(vehicle, 0)

    if props.plate       then SetVehicleNumberPlateText(vehicle, props.plate) end
    if props.plateIndex  then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
    if props.bodyHealth  then SetVehicleBodyHealth(vehicle,       props.bodyHealth  + 0.0) end
    if props.engineHealth then SetVehicleEngineHealth(vehicle,   props.engineHealth + 0.0) end
    if props.tankHealth  then SetVehiclePetrolTankHealth(vehicle, props.tankHealth) end
    if props.fuelLevel   then SetVehicleFuelLevel(vehicle,        props.fuelLevel  + 0.0) end
    if props.dirtLevel   then SetVehicleDirtLevel(vehicle,        props.dirtLevel  + 0.0) end
    if props.oilLevel    then SetVehicleOilLevel(vehicle,         props.oilLevel) end

    -- Primary colour
    if props.color1 then
        if type(props.color1) == "number" then
            ClearVehicleCustomPrimaryColour(vehicle)
            SetVehicleColours(vehicle, props.color1, currentColor2)
        else
            SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
        end
    end

    -- Secondary colour
    if props.color2 then
        if type(props.color2) == "number" then
            ClearVehicleCustomSecondaryColour(vehicle)
            SetVehicleColours(vehicle, currentColor1, props.color2)
        else
            SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
        end
    end

    if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, currentWheel) end
    if props.interiorColor    then SetVehicleInteriorColor(vehicle,  props.interiorColor) end
    if props.dashboardColor   then SetVehicleDashboardColour(vehicle, props.dashboardColor) end

    if props.wheelColor then
        local pearl = props.pearlescentColor or currentPearl
        SetVehicleExtraColours(vehicle, pearl, props.wheelColor)
    end

    if props.wheels    then SetVehicleWheelType(vehicle,  props.wheels) end
    if props.wheelSize then SetVehicleWheelSize(vehicle,  props.wheelSize) end
    if props.wheelWidth then SetVehicleWheelWidth(vehicle, props.wheelWidth) end

    -- Tyre health
    if props.tireHealth then
        for wheel, health in pairs(props.tireHealth) do
            SetVehicleWheelHealth(vehicle, wheel, health)
        end
    end

    -- Tyre burst – slow puncture
    if props.tireBurstState then
        for wheel, burst in pairs(props.tireBurstState) do
            if burst then SetVehicleTyreBurst(vehicle, tonumber(wheel), false, 1000.0) end
        end
    end

    -- Tyre burst – completely flat
    if props.tireBurstCompletely then
        for wheel, burst in pairs(props.tireBurstCompletely) do
            if burst then SetVehicleTyreBurst(vehicle, tonumber(wheel), true, 1000.0) end
        end
    end

    if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end

    if props.windowStatus then
        for window, intact in pairs(props.windowStatus) do
            if not intact then SmashVehicleWindow(vehicle, window) end
        end
    end

    if props.doorStatus then
        for door, damaged in pairs(props.doorStatus) do
            if damaged then SetVehicleDoorBroken(vehicle, tonumber(door), true) end
        end
    end

    if props.neonEnabled then
        SetVehicleNeonLightEnabled(vehicle, 0, props.neonEnabled[1])
        SetVehicleNeonLightEnabled(vehicle, 1, props.neonEnabled[2])
        SetVehicleNeonLightEnabled(vehicle, 2, props.neonEnabled[3])
        SetVehicleNeonLightEnabled(vehicle, 3, props.neonEnabled[4])
    end

    if props.neonColor       then SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3]) end
    if props.headlightColor  then SetVehicleHeadlightsColour(vehicle, props.headlightColor) end
    if props.interiorColor   then SetVehicleInteriorColour(vehicle,   props.interiorColor) end

    if props.tyreSmokeColor then
        SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
    end

    -- Mods (SetVehicleMod slots 0-49)
    if props.modSpoilers     then SetVehicleMod(vehicle,  0, props.modSpoilers,     false) end
    if props.modFrontBumper  then SetVehicleMod(vehicle,  1, props.modFrontBumper,  false) end
    if props.modRearBumper   then SetVehicleMod(vehicle,  2, props.modRearBumper,   false) end
    if props.modSideSkirt    then SetVehicleMod(vehicle,  3, props.modSideSkirt,    false) end
    if props.modExhaust      then SetVehicleMod(vehicle,  4, props.modExhaust,      false) end
    if props.modFrame        then SetVehicleMod(vehicle,  5, props.modFrame,        false) end
    if props.modGrille       then SetVehicleMod(vehicle,  6, props.modGrille,       false) end
    if props.modHood         then SetVehicleMod(vehicle,  7, props.modHood,         false) end
    if props.modFender       then SetVehicleMod(vehicle,  8, props.modFender,       false) end
    if props.modRightFender  then SetVehicleMod(vehicle,  9, props.modRightFender,  false) end
    if props.modRoof         then SetVehicleMod(vehicle, 10, props.modRoof,         false) end
    if props.modEngine       then SetVehicleMod(vehicle, 11, props.modEngine,       false) end
    if props.modBrakes       then SetVehicleMod(vehicle, 12, props.modBrakes,       false) end
    if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
    if props.modHorns        then SetVehicleMod(vehicle, 14, props.modHorns,        false) end
    if props.modSuspension   then SetVehicleMod(vehicle, 15, props.modSuspension,   false) end
    if props.modArmor        then SetVehicleMod(vehicle, 16, props.modArmor,        false) end
    if props.modKit17        then SetVehicleMod(vehicle, 17, props.modKit17,        false) end
    if props.modTurbo        then ToggleVehicleMod(vehicle, 18, props.modTurbo) end
    if props.modKit19        then SetVehicleMod(vehicle, 19, props.modKit19,        false) end
    if props.modSmokeEnabled then ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled) end
    if props.modKit21        then SetVehicleMod(vehicle, 21, props.modKit21,        false) end
    if props.modXenon        then ToggleVehicleMod(vehicle, 22, props.modXenon) end
    if props.modFrontWheels  then SetVehicleMod(vehicle, 23, props.modFrontWheels,  false) end
    if props.modBackWheels   then SetVehicleMod(vehicle, 24, props.modBackWheels,   false) end
    -- Custom tyre variants (re-apply with variation flag)
    if props.modCustomTiresF then SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF) end
    if props.modCustomTiresR then SetVehicleMod(vehicle, 24, props.modBackWheels,  props.modCustomTiresR) end
    if props.modPlateHolder  then SetVehicleMod(vehicle, 25, props.modPlateHolder,  false) end
    if props.modVanityPlate  then SetVehicleMod(vehicle, 26, props.modVanityPlate,  false) end
    if props.modTrimA        then SetVehicleMod(vehicle, 27, props.modTrimA,        false) end
    if props.modOrnaments    then SetVehicleMod(vehicle, 28, props.modOrnaments,    false) end
    if props.modDashboard    then SetVehicleMod(vehicle, 29, props.modDashboard,    false) end
    if props.modDial         then SetVehicleMod(vehicle, 30, props.modDial,         false) end
    if props.modDoorSpeaker  then SetVehicleMod(vehicle, 31, props.modDoorSpeaker,  false) end
    if props.modSeats        then SetVehicleMod(vehicle, 32, props.modSeats,        false) end
    if props.modSteeringWheel  then SetVehicleMod(vehicle, 33, props.modSteeringWheel,  false) end
    if props.modShifterLeavers then SetVehicleMod(vehicle, 34, props.modShifterLeavers, false) end
    if props.modAPlate       then SetVehicleMod(vehicle, 35, props.modAPlate,       false) end
    if props.modSpeakers     then SetVehicleMod(vehicle, 36, props.modSpeakers,     false) end
    if props.modTrunk        then SetVehicleMod(vehicle, 37, props.modTrunk,        false) end
    if props.modHydrolic     then SetVehicleMod(vehicle, 38, props.modHydrolic,     false) end
    if props.modEngineBlock  then SetVehicleMod(vehicle, 39, props.modEngineBlock,  false) end
    if props.modAirFilter    then SetVehicleMod(vehicle, 40, props.modAirFilter,    false) end
    if props.modStruts       then SetVehicleMod(vehicle, 41, props.modStruts,       false) end
    if props.modArchCover    then SetVehicleMod(vehicle, 42, props.modArchCover,    false) end
    if props.modAerials      then SetVehicleMod(vehicle, 43, props.modAerials,      false) end
    if props.modTrimB        then SetVehicleMod(vehicle, 44, props.modTrimB,        false) end
    if props.modTank         then SetVehicleMod(vehicle, 45, props.modTank,         false) end
    if props.modWindows      then SetVehicleMod(vehicle, 46, props.modWindows,      false) end
    if props.modKit47        then SetVehicleMod(vehicle, 47, props.modKit47,        false) end

    if props.modLivery then
        SetVehicleMod(vehicle, 48, props.modLivery, false)
        SetVehicleLivery(vehicle, props.modLivery)
    end

    if props.modKit49   then SetVehicleMod(vehicle, 49, props.modKit49, false) end
    if props.liveryRoof then SetVehicleRoofLivery(vehicle, props.liveryRoof) end
end

-- ── NUI focus toggle (debug command) ─────────────────────────────────────────

local nuiFocused = false
RegisterCommand("ra", function()
    nuiFocused = not nuiFocused
    SetNuiFocus(nuiFocused and 1 or 0, nuiFocused and 1 or 0)
end)

-- ── Anim dict loader ──────────────────────────────────────────────────────────

--- Request `dict` and block until it is loaded, then optionally call `cb`.
function Resmon.Lib.A11SFUNCTION(dict, cb)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(0)
        end
    end
    if cb ~= nil then cb() end
end

-- ── Model / asset loaders ─────────────────────────────────────────────────────

--- Stream a model hash and block until it is ready.
function Resmon.Lib.LoadModel(model)
    if HasModelLoaded(model) then return end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

--- Stream a weapon asset by name and block until ready.
function Resmon.Lib.LoadWeaponAsset(weaponName)
    local hash = GetHashKey(weaponName)
    if HasWeaponAssetLoaded(hash) then return end
    RequestWeaponAsset(hash, 31, 0)
    while not HasWeaponAssetLoaded(hash) do
        Wait(10)
    end
end

-- ── Object helpers ────────────────────────────────────────────────────────────

--- Return a list of objects whose model matches `model` within `radius` of `coords`.
--- `coords` defaults to the local ped position when nil.
function Resmon.Lib.GetClosestObjectsOfType(model, coords, radius)
    local ped     = PlayerPedId()
    local objects = GetGamePool("CObject")
    local result  = {}

    if coords then
        if type(coords) == "table" then
            coords = vec3(coords.x, coords.y, coords.z) or coords
        end
    else
        coords = GetEntityCoords(ped)
    end

    for i = 1, #objects do
        local obj = objects[i]
        if GetEntityModel(obj) == model then
            local objCoords = GetEntityCoords(obj)
            local dist = GetDistanceBetweenCoords(objCoords, coords, true)
            if dist <= radius then
                result[#result + 1] = obj
            end
        end
    end

    return result
end

-- ── Craft helpers ─────────────────────────────────────────────────────────────

--- Spawn `model` (weapon or prop) at the given world coordinates for use on a crafting table.
--- @param model   string   Model name or weapon name.
--- @param x,y,z  number   World position.
--- @param type   string   "weapon" or anything else (treated as prop).
function Resmon.Lib.Craft.LoadPropOnTable(model, x, y, z, type)
    local obj
    if type == "weapon" then
        Resmon.Lib.LoadWeaponAsset(model)
        obj = CreateWeaponObject(model, 0, x, y, z, true, 1.3, 0)
    else
        Resmon.Lib.LoadModel(model)
        obj = CreateObject(model, x, y, z, false, false, false)
    end
    SetModelAsNoLongerNeeded(model)
    return obj
end

-- ── Apartment helpers ─────────────────────────────────────────────────────────

--- Freeze (or unfreeze) the garage lift doors closest to `coords`.
function Resmon.Lib.Apartment._0xcfpFED(coords, freeze)
    local doors = Resmon.Lib.GetClosestObjectsOfType("v_ilev_garageliftdoor", coords, 3.0)
    for _, door in pairs(doors) do
        FreezeEntityPosition(door, freeze)
    end
end

-- ── Clothing URL helper (async) ───────────────────────────────────────────────

--- Fetch the clothing CDN URL from the server via callback (waits up to 1 s).
function getUrlDataClient()
    local p      = promise.new(promise)
    local result = nil

    Resmon.Lib.Callback.Client("pa-lib-2:getClothingUrl", function(url)
        result = url
    end)

    Citizen.Wait(1000)
    p:resolve(result)
    return Citizen.Await(p)
end
exports("getUrlDataClient", getUrlDataClient)

-- ── Craft V2 ─────────────────────────────────────────────────────────────────

function Resmon.Lib.Craft_V2.canOpenUI()
    return true
end

--- Convert a rotation vector to a unit forward-direction vector.
local function rotationToDirection(rot)
    local zRad = math.rad(rot.z)
    local xRad = math.rad(rot.x)
    local cosX = math.cos(xRad)
    return vector3(
        -math.sin(zRad) * cosX,
         math.cos(zRad) * cosX,
         math.sin(xRad)
    )
end

--- Spawn `model` at `coords` with optional `rotation` (vector3 or number = heading).
--- `networked`, `dynamic`, `noCollide` default to true, false, false.
local function spawnObject(model, coords, rotation, networked, dynamic, noCollide)
    if networked == nil then networked = true  end
    if dynamic   == nil then dynamic   = false end
    if noCollide == nil then noCollide = false end

    Resmon.Lib.LoadModel(model)
    local obj = CreateObject(model, coords.x, coords.y, coords.z, dynamic, dynamic, noCollide)
    SetEntityCoords(obj, coords.x, coords.y, coords.z, false, false, false, true)

    if rotation then
        if type(rotation) == "number" then
            rotation = vector3(0.0, 0.0, rotation)
        end
        SetEntityRotation(obj, rotation.x, rotation.y, rotation.z, 2, false)
    end

    FreezeEntityPosition(obj, networked)
    SetModelAsNoLongerNeeded(model)
    return obj
end

--- Spawn a preview object (prop or weapon) in front of `camera` for the crafting UI.
--- Returns (true, entity).
function Resmon.Lib.Craft_V2.createPreviewObject(model, attachments, camera)
    local camCoords = GetCamCoord(camera)
    local camRot    = GetCamRot(camera, 2)
    local dir       = rotationToDirection(camRot)
    local spawnPos  = camCoords + dir * 1.2

    local previewObj = nil

    if model:lower():sub(0, 7) == "weapon_" then
        -- ── Weapon preview ────────────────────────────────────────────────────
        Resmon.Lib.LoadWeaponAsset(model)
        local weaponHash = GetWeapontypeModel(model)
        Resmon.Lib.LoadModel(weaponHash)

        local obj = CreateWeaponObject(model, 0, spawnPos.x, spawnPos.y, spawnPos.z + 0.1, true, 1.3, 0)
        while not DoesEntityExist(obj) do Wait(0) end

        -- Hide while attaching components
        SetEntityAlpha(obj, 0)
        SetEntityRotation(obj, 0.0, 0.0, (camRot.z + 180.0) % 360.0)
        previewObj = obj

        local skinAttachment = nil
        for _, attachment in ipairs(attachments) do
            if attachment.name == "skin" then
                skinAttachment = attachment
            else
                local hash = attachment.hash
                if type(hash) == "string" then
                    hash = GetHashKey(hash) or hash
                end
                local compModel = GetWeaponComponentTypeModel(hash)
                Resmon.Lib.LoadModel(compModel)
                GiveWeaponComponentToWeaponObject(obj, hash)
                SetModelAsNoLongerNeeded(compModel)
            end
        end

        if skinAttachment then
            SetWeaponObjectTintIndex(obj, 2)
        end

        SetEntityAlpha(obj, 255)
        RemoveWeaponAsset(model)
        SetModelAsNoLongerNeeded(weaponHash)
    else
        -- ── Prop preview ──────────────────────────────────────────────────────
        previewObj = spawnObject(model, spawnPos, nil, true, false, false)
    end

    return true, previewObj
end

-- ── NUI licence callbacks (always granted) ────────────────────────────────────

RegisterNUICallback("hasillegalpacklicense", function(data, cb)
    cb(true)
end)

RegisterNUICallback("haslicense", function(data, cb)
    cb(true)
end)