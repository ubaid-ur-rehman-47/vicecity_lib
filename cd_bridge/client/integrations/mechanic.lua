--- @param vehicle number The vehicle entity.
--- @return table | nil # Returns a table of the vehicle properties, or nil if the integration is not available.
function GetVehicleProperties_Custom(vehicle)
    if Cfg.Mechanic == 'none' then return end

    if Cfg.Mechanic == 'jg-mechanic' then
        return exports['jg-mechanic']:getVehicleProperties(vehicle)
    end
end

--- @param vehicle number The vehicle entity.
--- @param props table A table containing the vehicle properties to set.
--- @return boolean | nil # Returns true if the properties were successfully set, or nil if the integration is not available.
function SetVehicleProperties_Custom(vehicle, props)
    if Cfg.Mechanic == 'none' then return nil end

    if Cfg.Mechanic == 'jg-mechanic' then
        exports['jg-mechanic']:setVehicleProperties(vehicle, props)
        return true
    end

    return nil
end