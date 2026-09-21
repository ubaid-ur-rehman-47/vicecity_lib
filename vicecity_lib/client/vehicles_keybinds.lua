--[[
    Example keybind — toggle lock on the vehicle the player is nearest to,
    demonstrating ViceCity.RegisterKeybind. Safe to delete/replace in a
    consuming resource.
]]

ViceCity.RegisterKeybind('vicecity:togglelock', 'Toggle nearest vehicle lock', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        local coords = GetEntityCoords(ped)
        vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    end
    if vehicle == 0 then return end
    local plate = GetVehicleNumberPlateText(vehicle)
    ViceCity.VehicleKeys.ClientToggleLock(vehicle, plate)
end, 'keyboard', 'L')
