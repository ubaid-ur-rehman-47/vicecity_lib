-- Get all possible plate variations for a given plate.
function GetAllPossiblePlates(plate)
    local results = {}
    local seen = {}

    local function add(p)
        if p and p ~= '' and not seen[p] then
            seen[p] = true
            table.insert(results, p)
        end
    end

    add(plate)

    local trimmed = plate:match('^%s*(.-)%s*$')
    add(trimmed)

    if #trimmed < 8 then
        add(GenerateSpacesInPlate(trimmed))
    end

    return results
end

-- Check if a vehicle exists in the database.
function IsVehicleOwned(plate)
    local exists = DB.exists('SELECT 1 FROM '..FW.vehicle_table..' WHERE plate = ? LIMIT 1', { plate })
    if exists then
        return true
    else
        return false
    end
end

-- Check if a player owns a vehicle.
function DoesPlayerOwnVehicle(source, plate)
    if type(plate) ~= 'string' or plate == '' then
        return false
    end
    local identifier = GetIdentifier(source)

    return DB.exists(('SELECT 1 FROM '..FW.vehicle_table..' WHERE plate = ? AND '..FW.vehicle_identifier..' = ? LIMIT 1'), { plate, identifier }) == true
end

-- Generate a random vehicle plate.
function GenerateRandomVehiclePlate(plateFormat)
    plateFormat = plateFormat or 'AAAA1111'
    local plate = ''
    local letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    local numbers = '0123456789'

    for cd = 1, #plateFormat do
        local char = string.sub(plateFormat, cd, cd)
        if char == 'A' then
            local random_index = math.random(1, #letters)
            local random_char = string.sub(letters, random_index, random_index)
            plate = plate..random_char
        elseif char == '1' then
            local random_index = math.random(1, #numbers)
            local random_char = string.sub(numbers, random_index, random_index)
            plate = plate..random_char
        else
            plate = plate..char
        end
    end

    local Result = DB.fetch('SELECT plate FROM '..FW.vehicle_table..' WHERE plate=?', {plate})
    if Result and Result[1] == nil then
        return plate
    else
        return GenerateRandomVehiclePlate()
    end
end

-- Fetch vehicle properties from the database.
function GetVehiclePropertiesFromDatabase(plate)
    local vehicle = DB.fetch('SELECT '..FW.vehicle_props..' FROM '..FW.vehicle_table..' WHERE plate=?', {plate})
    if vehicle and vehicle[1] and vehicle[1][FW.vehicle_props] then
        return json.decode(vehicle[1][FW.vehicle_props] or '{}')
    end
    return {}
end

-- Gets vehicles license plate.
function GetVehiclePlate(vehicle)
    if not vehicle then
        return
    end
    local plate = GetVehicleNumberPlateText(vehicle)
    return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end

-- Called from a callback, used to force exit players out of a vehicle.
function KickOutPlayersInVehicle(src, players, forceKickout, netID)
    local entID = NetworkGetEntityFromNetworkId(netID)
    local vehicle = entID and DoesEntityExist(entID) and entID or nil

    for _, source in pairs(players) do
        local ped = GetPlayerPed(source)
        if not forceKickout and vehicle then
            TaskLeaveVehicle(ped, vehicle, 256)
            TaskLeaveAnyVehicle(ped, 0, 0)
        elseif forceKickout then
            local coords = GetEntityCoords(ped)
            SetEntityCoords(ped, coords.x, coords.y, coords.z)
        end
    end

    if (forceKickout) or (not forceKickout and not vehicle) then return true end

    local timeout = 4000
    local start = GetGameTimer()

    while true do
        Wait(100)
        local allLeft = true

        for _, source in pairs(players) do
            local ped = GetPlayerPed(source)
            if GetVehiclePedIsIn(ped, false) == vehicle then
                allLeft = false
                break
            end
        end

        if allLeft or (GetGameTimer() - start) >= timeout then
            if not allLeft then
                for _, source in pairs(players) do
                    local ped = GetPlayerPed(source)
                    local coords = GetEntityCoords(ped)
                    SetEntityCoords(ped, coords.x, coords.y, coords.z)
                end
            end
            break
        end
    end
    return true
end

-- Gets closest vehicle to player.
function GetClosestVehicleToPlayer(source, maxDistance)
    local ped = GetPlayerPed(source)
    if not ped or ped == 0 then return false end

    local currentVehicle = GetVehiclePedIsIn(ped, false)
    if currentVehicle and currentVehicle ~= 0 then
        return currentVehicle
    end

    local pedCoords = GetEntityCoords(ped)
    local closestVeh, closestDist = nil, maxDistance or 1000

    local vehicles = GetAllVehicles()

    for cd = 1, #vehicles do
        local veh = vehicles[cd]

        if DoesEntityExist(veh) then
            local vehCoords = GetEntityCoords(veh)
            local dist = #(pedCoords - vehCoords)

            if dist < closestDist then
                closestDist = dist
                closestVeh = veh
            end
        end
    end

    return closestVeh or false
end