--- @param input number|string Vehicle entity/network ID or plate
--- @return number|nil # The mileage of the vehicle, or nil if not available
function GetVehicleMileage(input)
    local vehicle, plate = GetVehicleAndOrPlateFromSingleInput(input)

    if not vehicle and not plate then
        ERROR('7567', 'GetVehicleMileage called with invalid vehicle or plate')
        return nil
    end

    if Cfg.VehicleMileage == 'none' then
        return nil
    end

    if Cfg.VehicleMileage == 'cd_mechanic' then
        return exports.cd_mechanic:GetMileage(vehicle or plate)

    elseif Cfg.VehicleMileage == 'cd_garage' then
        return exports.cd_garage:GetMileage(vehicle or plate)

    elseif Cfg.VehicleMileage == 'jg-vehiclemileage' then
        if vehicle then
            return exports['jg-vehiclemileage']:getMileageByEntity(vehicle)
        end
        if plate then
            return exports['jg-vehiclemileage']:getMileageByPlate(plate)
        end

    elseif Cfg.VehicleMileage == 'other' then
        -- Custom integration for other mileage systems
    end
end


if Cfg.VehicleMileage ~= 'jg-vehiclemileage' then
    RegisterLegacyExport('jg-vehiclemileage', 'getMileageByEntity', function(vehicle)
        return GetVehicleMileage(vehicle)
    end)

    RegisterLegacyExport('jg-vehiclemileage', 'getMileageByPlate', function(plate)
        return GetVehicleMileage(plate)
    end)

    RegisterLegacyExport('jg-vehiclemileage', 'GetMileage', function(vehicle)
        return GetVehicleMileage(vehicle)
    end)
end