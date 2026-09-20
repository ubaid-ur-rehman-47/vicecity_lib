local function getPedGender(ped)
    ped = ped or PlayerPedId()
    if IsPedModel(ped, `mp_f_freemode_01`) then
        return Locale('female')
    elseif IsPedModel(ped, `mp_m_freemode_01`) then
        return Locale('male')
    else
        return Locale('person')
    end
end

local ColourGroups = {
    black = { 0, 1, 2, 11, 12, 15, 16, 21, 147 },
    grey = { 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 17, 18, 19, 20, 22, 23, 24, 25, 26, 66, 93, 144, 156 },
    white = { 106, 107, 111, 112, 113, 121, 122, 131, 132, 134 },
    red = { 27, 28, 29, 30, 31, 32, 33, 34, 35, 39, 40, 43, 44, 46, 143, 150 },
    pink = { 135, 136, 137 },
    blue = { 54, 60, 61, 62, 63, 64, 65, 67, 68, 69, 70, 73, 74, 75, 77, 78, 79, 80, 82, 83, 84, 85, 86, 87, 127, 140, 141, 146, 157 },
    yellow = { 42, 88, 89, 91, 126 },
    green = { 49, 50, 51, 52, 53, 55, 56, 57, 58, 59, 92, 125, 128, 133, 151, 152, 155 },
    orange = { 36, 38, 41, 123, 124, 130, 138 },
    brown = { 45, 47, 48, 90, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 108, 109, 110, 114, 115, 116, 129, 153, 154 },
    purple = { 71, 72, 76, 81, 142, 145, 148, 149 },
    chrome = { 117, 118, 119, 120 },
    gold  = { 37, 158, 159, 160 }
}

local CarColours = {}
local VehicleColourLookup = {}

for label, indexes in pairs(ColourGroups) do
    CarColours[label] = {}

    for i = 1, #indexes do
        local index = indexes[i]

        CarColours[label][#CarColours[label] + 1] = {
            index = index,
            label = label
        }

        VehicleColourLookup[index] = label
    end
end

local function getVehicleColour(vehicle)
    local primary = select(1, GetVehicleColours(vehicle))
    return VehicleColourLookup[primary] or Locale('unknown')
end

local function getHeading(heading)
    if heading >= 315 or heading < 45 then
        return Locale('north_bound')
    elseif heading >= 45 and heading < 135 then
        return Locale('west_bound')
    elseif heading >= 135 and heading < 225 then
        return Locale('south_bound')
    elseif heading >= 225 and heading < 315 then
        return Locale('east_bound')
    end
    return ''
end

function GetPlayerInfo()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local inVehicle = IsPedInAnyVehicle(ped, false)
    local vehicle = inVehicle and GetVehiclePedIsIn(ped, false)
    local hasVehicle = vehicle and vehicle ~= 0
    local streetNames = GetStreetNames(coords)

    return {
        ped = ped,
        coords = coords,
        street = streetNames.streetName .. ', ' .. streetNames.zoneName,
        gender = getPedGender(ped),
        vehicle = hasVehicle and vehicle or nil,
        vehicle_label = hasVehicle and GetVehicleLabel(vehicle) or nil,
        vehicle_colour = hasVehicle and getVehicleColour(vehicle) or nil,
        vehicle_plate = hasVehicle and GetVehiclePlate(vehicle) or nil,
        vehicle_heading = inVehicle and hasVehicle and getHeading(GetEntityHeading(ped)) or nil,
        vehicle_speed = inVehicle and hasVehicle and GetEntitySpeed(vehicle) * 2.236936 or 0.0,
    }
end

--[[
local playerInfo = GetPlayerInfo()
SendDispatchCall({
    title = 'Test Dispatch',
    message = 'This is a test dispatch message.',
    code = '10-99',

    jobs = {'police', 'ambulance'},
    high_priority = true,

    coords = playerInfo.coords,
    gender = playerInfo.gender,
    street = playerInfo.street,

    blip = {
        sprite = 60,
        colour = 3,
        flash = true
    },
})
]]

function SendDispatchCall(data)
    if Cfg.Dispatch == 'none' then return end


    if Cfg.Dispatch == 'cd_dispatch' or Cfg.Dispatch == 'cd_dispatch3d' then
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = data.jobs,
            coords    = data.coords,
            title     = data.title,
            message   = data.message,
            flash     = data.high_priority,
            unique_id = Cfg.Dispatch == 'cd_dispatch' and GenerateUniqueId() or nil,
            sound     = data.high_priority and 3 or 1,
            blip = {
                sprite  = data.blip.sprite,
                scale   = 1.0,
                colour  = data.blip.colour,
                flashes = data.blip.flash,
                text    = data.title,
                time    = 5,
                radius  = 0,
            }
        })

    elseif Cfg.Dispatch == 'codem-dispatch' then
        exports['codem-dispatch']:CustomDispatch({
            type = 'Robbery',
            header = data.title,
            text = data.message,
            code = data.code,
        })

    elseif Cfg.Dispatch == 'codem-mdtv2' then
        for _, job in pairs(data.jobs) do
            TriggerServerEvent('codem-dispatchv2:server:sendAlert', {
                type = job,
                title = data.title,
                description = data.message,
                coords = data.coords,
                blip = {
                    sprite = data.blip.sprite,
                    color = data.blip.color,
                    scale = 1.0,
                    length = 5,
                }
            })
        end

    elseif Cfg.Dispatch == 'core_dispatch' then
        for _, job in pairs(data.jobs) do
            TriggerServerEvent('core_dispatch:server:sendAlert', {
                data.message,
                { {icon = 'fa-venus-mars', info = data.gender} },
                { data.coords.x, data.coords.y, data.coords.z },
                job,
                5000,
                data.blip.sprite,
                data.blip.color,
                data.high_priority
            })
        end

    elseif Cfg.Dispatch == 'emergencydispatch' then
        -- Whos script is this?

    elseif Cfg.Dispatch == 'lb-tablet' then
        exports['lb-tablet']:AddDispatch({
            priority = data.high_priority and 'high' or 'medium',
            code = data.code,
            title = data.title,
            description = data.message,
            location = {
                label = data.street,
                coords = vector2(data.coords.x, data.coords.y)
            },
            time = 60,
            sound = data.blip.flash and 'notification2.mp3' or 'notification.mp3',
            blip = {
                sprite = data.blip.sprite,
                color = data.blip.colour,
                size = 1.0,
                shortRange = true,
                label = data.title
            }
        })

    elseif Cfg.Dispatch == 'origen_police' then
        for _, job in pairs(data.jobs) do
            TriggerServerEvent('SendAlert:police', {
                coords = data.coords,
                title = data.title,
                type = 'GENERAL',
                message = data.message,
                job = job,
                metadata = {
                    model = data.vehicle_label,
                    color = data.vehicle_colour,
                    plate = data.vehicle_plate,
                    speed = data.vehicle_speed,
                }
            })
        end

    elseif Cfg.Dispatch == 'ps-dispatch' then
        TriggerServerEvent('ps-dispatch:server:notify', {
            jobs = data.jobs,
            message = data.message,
            codeName = 'none',
            code = data.code,
            icon = 'fas fa-question',
            priority = data.high_priority and 1 or 2,
            coords = data.coords,
            gender = data.gender,
            street = data.street,
            alertTime = 10,
            alert = {
                radius = 0,
                sprite = data.blip.sprite,
                color = data.blip.colour,
                scale = 1.0,
                length = 2,
                sound = 'Lose_1st',
                sound2 = 'GTAO_FM_Events_Soundset',
                flash = data.blip.flash
            },
        })

    elseif Cfg.Dispatch == 'qs-dispatch' then
        TriggerServerEvent('qs-dispatch:server:CreateDispatchCall', {
            job = data.jobs,
            callLocation = data.coords,
            callCode = {code = data.code, name = data.title},
            message = data.message,
            blip = {
                sprite = data.blip.sprite,
                scale = 1.0,
                colour = data.blip.color,
                flashes = data.blip.flash ,
                text = data.title,
                time = 10000,
            },
        })

    elseif Cfg.Dispatch == 'rcore_dispatch' then
        TriggerServerEvent('rcore_dispatch:server:sendAlert', {
            code = data.code,
            default_priority = data.high_priority and 'high' or 'medium',
            coords = data.coords,
            job = data.jobs,
            text = data.message,
            type = 'alerts',
            blip = {
                sprite = data.blip.sprite,
                colour = data.blip.color,
                scale = 1.0,
                text = data.title,
                flashes = data.blip.flash,
                radius = 0,
            }
        })

    elseif Cfg.Dispatch == 'tk_dispatch' then
        exports.tk_dispatch:addCall({
            title = data.title,
            coords = data.coords,
            showLocation = true,
            showGender = true,
            playSound = true,
            priority = data.high_priority and 'Important' or nil,
            blip = {
                color = data.blip.colour,
                sprite = data.blip.sprite,
                scale = 1.0,
            },
            jobs = data.jobs
        })

    elseif Cfg.Dispatch == 'other' then
        -- Implement custom dispatch integration here.
    end
end
