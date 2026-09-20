-- Normalizes a vehicle plate by trimming whitespace from both ends.
function NormalizeVehiclePlate(plate)
    return string.gsub(plate, "^%s*(.-)%s*$", "%1")
end

-- Gets vehicle and/or plate from either vehicle entity, vehicle plate or netId.
function GetVehicleAndOrPlateFromSingleInput(input)
    local vehicle = nil
    local plate = nil

    if type(input) == 'number' then
        if input ~= 0 then
            local entity = input

            if not DoesEntityExist(entity) then
                entity = NetworkGetEntityFromNetworkId(input)
            end

            if entity and entity ~= 0 and DoesEntityExist(entity) then
                vehicle = entity
                plate = NormalizeVehiclePlate(GetVehicleNumberPlateText(entity))
            end
        end

    elseif type(input) == 'string' then
        plate = NormalizeVehiclePlate(input)
    end

    return vehicle, plate
end

-- Find vehicle entity id from plate.
function GetVehiclePlateFromVehicleEntityId(vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return nil end
    local plate = GetVehiclePlate(vehicle)
    if not plate or plate == '' then return nil end
    return NormalizeVehiclePlate(plate)
end