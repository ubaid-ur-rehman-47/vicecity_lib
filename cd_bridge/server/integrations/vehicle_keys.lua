-- Triggered when giving keys to a vehicle.
--- @param source number The players source.
--- @param plate string The vehicle plate.
--- @param vehicle number|nil The vehicle entity.
function GiveVehicleKeys(source, plate, vehicle)
    TriggerClientEvent('cd_bridge:GiveVehicleKeys', source, plate, vehicle)
end

-- Triggered when removing keys from a vehicle
--- @param source number The players source.
--- @param plate string The vehicle plate.
--- @param vehicle number|nil The vehicle entity.
function RemoveVehicleKeys(source, plate, vehicle)
    TriggerClientEvent('cd_bridge:RemoveVehicleKeys', source, plate, vehicle)
end



-- ┌──────────────────────────────────────────────────────────────────┐
-- │                    BACKWARDS COMPATIBILITY                       │
-- └──────────────────────────────────────────────────────────────────┘

RegisterLegacyExport('qbx_vehiclekeys', 'GiveKeys', function(source, vehicle)
    local plate = GetVehiclePlateFromVehicleEntityId(vehicle)
    GiveVehicleKeys(source, plate, vehicle)
end)

RegisterLegacyExport('qbx_vehiclekeys', 'RemoveKeys', function(source, vehicle)
    local plate = GetVehiclePlateFromVehicleEntityId(vehicle)
    RemoveVehicleKeys(source, plate, vehicle)
end)