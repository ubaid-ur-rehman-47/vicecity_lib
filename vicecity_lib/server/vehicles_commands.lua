--[[
    Example vehicle CRUD commands — demonstrates ViceCity.RegisterCommand and
    the garage-integrated vehicle CRUD facade. Admin-restricted via the
    framework permission check; safe to delete/replace in a consuming resource.
]]

ViceCity.RegisterCommand('vehicle:create', function(source, args)
    if source ~= 0 and not ViceCity.Framework.HasPermission(source, 'admin') then return end
    local plate, model, owner = args[1], args[2], args[3] or ViceCity.Framework.GetIdentifier(source)
    if not plate or not model then return end
    local ok, result = ViceCity.Garage.ServerCreateVehicle(plate, model, owner)
    print(('[vicecity_lib] vehicle:create %s -> %s'):format(plate, tostring(ok)))
end, { restricted = false, help = 'Create a vehicle for a player', suggest = true })

ViceCity.RegisterCommand('vehicle:delete', function(source, args)
    if source ~= 0 and not ViceCity.Framework.HasPermission(source, 'admin') then return end
    local plate = args[1]
    if not plate then return end
    local ok, result = ViceCity.Garage.ServerDeleteVehicle(plate)
    print(('[vicecity_lib] vehicle:delete %s -> %s'):format(plate, tostring(ok)))
end, { restricted = false, help = 'Delete a player vehicle', suggest = true })
