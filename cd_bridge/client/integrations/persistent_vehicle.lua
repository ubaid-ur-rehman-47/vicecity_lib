--- @param vehicle number The vehicle entity.
--- @param plate string The vehicle plate.
function RegisterPersistentVehicle(vehicle, plate, cd)
    local net_id = NetworkGetNetworkIdFromEntity(vehicle)

    if Cfg.PersistentVehicles == 'cd_garage' then
        Entity(vehicle).state:set('cd_persistent_plate', NormalizeVehiclePlate(plate), true)
        TriggerServerEvent('cd_garage:PersistentVehicles:Add', plate, net_id, cd)

    elseif Cfg.PersistentVehicles == 'AdvancedParking' then
        exports.AdvancedParking:UpdateVehicle(vehicle)

    elseif Cfg.PersistentVehicles == 'other' then
        --Add your own code here if needed.
    end
end

--- @param vehicle number The vehicle entity.
--- @param plate string  The vehicle plate.
function UnRegisterPersistentVehicle(vehicle, plate)
    if Cfg.PersistentVehicles == 'cd_garage' then
        TriggerServerEvent('cd_garage:PersistentVehicles:Remove', plate)

    elseif Cfg.PersistentVehicles == 'AdvancedParking' then
        exports.AdvancedParking:DeleteVehicle(vehicle)

    elseif Cfg.PersistentVehicles == 'other' then
        --Add your own code here if needed.
    end
end

--- @param vehicle number The vehicle entity.
--- @param oldPlate string The vehicles old plate.
--- @param newPlate string The vehicles new plate.
function PersistentVehiclePlateUpdated(vehicle, oldPlate, newPlate)
    if Cfg.PersistentVehicles == 'cd_garage' then
        TriggerServerEvent('cd_garage:PersistentVehicles:PlateChanged', oldPlate, newPlate)

    elseif Cfg.PersistentVehicles == 'AdvancedParking' then
        exports.AdvancedParking:UpdatePlate(vehicle, newPlate)

    elseif Cfg.PersistentVehicles == 'other' then
        --Add your own code here if needed.
    end
end
