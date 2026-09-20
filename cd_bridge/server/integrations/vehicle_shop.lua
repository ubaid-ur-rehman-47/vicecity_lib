--- @return table | nil # A table of shared vehicles, where the key is the vehicle hash and the value is a table containing the vehicle's name, model, hash, price, and category. Returns nil if the integration is not available.
function GetCustomSharedVehicles()
    if Cfg.VehicleShop == 'okokVehicleShop' then
        local data = DB.fetch('SELECT vehicle_name, vehicle_id, category, min_price, max_price FROM okokvehicleshop_vehicles')
        if not data then return nil end

        local sharedVehicles = {}
        for _, vehicle in pairs(data) do
            if vehicle.vehicle_id ~= nil then
                local hash = GetHashKey(vehicle.vehicle_id)
                sharedVehicles[hash] = {
                    name = vehicle.vehicle_name,
                    model = vehicle.vehicle_id,
                    hash = hash,
                    price = math.floor(((vehicle.min_price + vehicle.max_price) / 2) + 0.5),
                    category = vehicle.category
                }
            end
        end
        return sharedVehicles

    elseif Cfg.VehicleShop == 'jg-dealerships' then
        local data = DB.fetch('SELECT spawn_code, model, category, price FROM dealership_vehicles')
        if not data then return nil end

        local sharedVehicles = {}
        for _, vehicle in pairs(data) do
            local hash = GetHashKey(vehicle.spawn_code)
            sharedVehicles[hash] = {
                name = vehicle.model,
                model = vehicle.spawn_code,
                hash = hash,
                price = vehicle.price,
                category = vehicle.category
            }
        end
        return sharedVehicles



    elseif Cfg.VehicleShop == 'other' then
        -- Return a table of vehicles and their data.
        return {}
    end
end

-- Get the location of the shared vehicles data for the servers framework, or custom location if a custom vehicle shop is being used.
function GetSharedVehiclesLocation()
    if Cfg.VehicleShop == 'okokVehicleShop' then
        return '"okokvehicleshop_vehicles" database table'

    elseif Cfg.VehicleShop == 'jg-dealerships' then
        return '"dealership_vehicles" database table'
    end

    local frameworkLocations = {
        esx = '"vehicles" database table',
        qbcore = 'qb-core/shared/vehicles.lua',
        qbox = 'qbx_core/shared/vehicles.lua'
    }

    return frameworkLocations[Config.Framework] or Locale('unknown')
end



-- ┌──────────────────────────────────────────────────────────────────┐
-- │                    BACKWARDS COMPATIBILITY                       │
-- └──────────────────────────────────────────────────────────────────┘

AddEventHandler('dealerships_creator:giveVehicleToPlayerId', function(playerId, vehicleName, plate)
    GiveVehicleKeys(playerId, plate, nil)
    TriggerClientEvent('cd_garage:UpdateGarageType', playerId)
end)

AddEventHandler('dealerships_creator:dealerships:onVehicleResell', function(dealershipId, plate, vehicleName, playerId, resellPrice)
    RemoveVehicleKeys(playerId, plate, nil)
end)

AddEventHandler('esx_vehicleshop:rentVehicle', function(vehicle, plate, rentPrice, playerId)
    GiveVehicleKeys(playerId, plate, nil)
end)


AddEventHandler('esx_vehicleshop:setVehicleOwnedPlayerId', function(playerId, vehicleProps, model, label)
    TriggerClientEvent('cd_garage:UpdateGarageType', playerId)
end)

AddEventHandler('qbx_vehicleshop:server:buyShowroomVehicle', function(modelHash)
    TriggerClientEvent('cd_garage:UpdateGarageType', source)
end)

AddEventHandler('jg-advancedgarages:server:dealerships-send-to-default-garage', function(plate, garageType)
    TriggerEvent('cd_garage:SendToDefaultGarage', plate, garageType)
end)