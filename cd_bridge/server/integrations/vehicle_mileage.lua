--- @param vehicle number The vehicle entity ID
--- @param plate? string The vehicle plate number
--- @return number|nil # The mileage of the vehicle, or nil if not available
function GetVehicleMileage(vehicle, plate)
    if not vehicle then
        ERROR('7567', 'GetVehicleMileage called without vehicle')
        return nil
    end

    if Cfg.VehicleMileage == 'none' then
        return nil
    end

    plate = plate or GetVehiclePlate(vehicle)

    if Cfg.VehicleMileage == 'cd_mechanic' then
        return exports.cd_mechanic:GetMileage(vehicle)

    elseif Cfg.VehicleMileage == 'cd_garage' then
        return exports.cd_garage:GetMileage(vehicle)

    elseif Cfg.VehicleMileage == 'jg-vehiclemileage' then
        return exports['jg-vehiclemileage']:getMileageByEntity(vehicle)

    elseif Cfg.VehicleMileage == 'other' then
        -- Custom integration for other mileage systems
    end
end

--- @return string|nil # The database column name for vehicle mileage, or nil if not available
function GetVehicleMileageDatabaseColumn()
    if Cfg.VehicleMileage == 'none' then
        return nil
    end

    if Cfg.VehicleMileage == 'cd_mechanic' then
        return FW.vehicle_mileage

    elseif Cfg.VehicleMileage == 'cd_garage' then
        return FW.vehicle_mileage

    elseif Cfg.VehicleMileage == 'jg-vehiclemileage' then
        return 'mileage'

    elseif Cfg.VehicleMileage == 'other' then
        -- Custom integration for other mileage systems
    end
end

if Cfg.VehicleMileage ~= 'jg-vehiclemileage' then
    RegisterLegacyExport('jg-vehiclemileage', 'getMileageByEntity', function(vehicle)
        return GetVehicleMileage(vehicle)
    end)
end