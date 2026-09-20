--- @param plate string The vehicle plate.
--- @param vehicle number|nil The vehicle entity.
function GiveVehicleKeys(plate, vehicle) -- Triggered when giving keys to a vehicle (vehicle may be nil).
    local keysResource = Cfg.VehicleKeys
    if keysResource == 'cd_garage' then
        TriggerEvent('cd_garage:AddKeys', plate, vehicle)
    elseif keysResource == 'ak47_qb_vehiclekeys' then
        exports.ak47_qb_vehiclekeys:GiveKey(plate, false)
    elseif keysResource == 'ak47_vehiclekeys' then
        exports.ak47_vehiclekeys:GiveKey(plate, false)
    elseif keysResource == 'fast-vehiclekeys' then
        TriggerServerEvent('fast-vehiclekeys:GiveTempKey', plate)
    elseif keysResource == 'fivecode_carkeys' then
        exports.fivecode_carkeys:GiveKey(vehicle, false, true)
    elseif keysResource == 'F_RealCarKeysSystem' then
        TriggerServerEvent('F_RealCarKeysSystem:generateVehicleKeys', plate)
    elseif keysResource == 'ic3d_vehiclekeys' then
        exports.ic3d_vehiclekeys:ClientInventoryKeys('add', plate)
    elseif keysResource == 'is_vehiclekeys' then
        exports.is_vehiclekeys:GiveKey(plate)
    elseif keysResource == 'jc_vehiclekeys' then
        exports.jc_vehiclekeys:GiveKeys(plate)
    elseif keysResource == 'mk_vehiclekeys' then
        exports.mk_vehiclekeys:AddKey(vehicle)
    elseif keysResource == 'mm_carkeys' then
        exports.mm_carkeys:GiveTempKeys(plate)
    elseif keysResource == 'MrNewbVehicleKeys' then
        exports.MrNewbVehicleKeys:GiveKeysByPlate(plate)
    elseif keysResource == 'mx_carkeys' then
        exports.mx_carkeys:createTempKey(vehicle, plate, 2)
    elseif keysResource == 'qs-vehiclekeys' then
        exports['qs-vehiclekeys']:GiveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true)
    elseif keysResource == 'Renewed-Vehiclekeys' then
        exports['Renewed-Vehiclekeys']:addKey(plate)
    elseif keysResource == 'stasiek_vehiclekeys' then
        DecorSetInt(vehicle, 'owner', GetPlayerServerId(PlayerId()))
    elseif keysResource == 'tc_keys' then
        TriggerEvent('tc_keys:client:giveAccess', plate)
    elseif keysResource == 't1ger_keys' then
        exports['t1ger_keys']:GiveTemporaryKeys(plate, GetLabelText(GetDisplayNameFromVehicleModel(vehicle)), type)
    elseif keysResource == 'tgiann-hotwire' then
        exports['tgiann-hotwire']:GiveKeyPlate(plate, true)
    elseif keysResource == 'ti_vehicleKeys' then
        exports.ti_vehicleKeys:addTemporaryVehicle(plate)
    elseif keysResource == 'vehicles_keys' then
        TriggerServerEvent('vehicles_keys:selfGiveVehicleKeys', plate)
    elseif keysResource == 'wasabi_carlock' then
        exports.wasabi_carlock:GiveKey(plate)
    elseif keysResource == 'xd_locksystem' then
        local success = pcall(function()
            exports.xd_locksystem:givePlayerKeys(plate) -- v1
        end)
        if not success then
            pcall(function()
                exports.xd_locksystem:SetVehicleKey(plate) -- v2
            end)
        end
    elseif keysResource == 'qbx_vehiclekeys' then
        TriggerServerEvent('qbx_vehiclekeys:server:tookKeys', NetworkGetNetworkIdFromEntity(vehicle))
    elseif keysResource == 'qb-vehiclekeys' then
        TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', plate)
    elseif keysResource == 'other' then
        --- Implement other vehicle keys give method here.
    elseif keysResource == 'none' then

    end
end

RegisterNetEvent('cd_bridge:GiveVehicleKeys', function(plate, vehicle)
    GiveVehicleKeys(plate, vehicle)
end)

--- @param plate string The vehicle plate.
--- @param vehicle number|nil The vehicle entity.
function RemoveVehicleKeys(plate, vehicle) -- Triggered when removing keys from a vehicle (vehicle may be nil).
    local keysResource = Cfg.VehicleKeys
    if keysResource == 'cd_garage' then
        TriggerEvent('cd_garage:RemoveKeys', plate)
    elseif keysResource == 'ak47_qb_vehiclekeys' then
        exports.ak47_qb_vehiclekeys:RemoveKey(plate, false)
    elseif keysResource == 'ak47_vehiclekeys' then
        exports.ak47_vehiclekeys:RemoveKey(plate, false)
    elseif keysResource == 'fast-vehiclekeys' then
        TriggerServerEvent('fast-vehiclekeys:RemoveTempKey', plate)
    elseif keysResource == 'fivecode_carkeys' then
        exports.fivecode_carkeys:StoreVehicleKey(vehicle, true)
    elseif keysResource == 'F_RealCarKeysSystem' then
        TriggerServerEvent('F_RealCarKeysSystem:removeVehicleKeys', plate)
    elseif keysResource == 'ic3d_vehiclekeys' then
        exports.ic3d_vehiclekeys:ClientInventoryKeys('remove', plate)
    elseif keysResource == 'is_vehiclekeys' then
        exports.is_vehiclekeys:RemoveKey(plate)
    elseif keysResource == 'jc_vehiclekeys' then
        exports.jc_vehiclekeys:RemoveKeys(plate)
    elseif keysResource == 'mk_vehiclekeys' then
        exports.mk_vehiclekeys:RemoveKey(vehicle)
    elseif keysResource == 'mm_carkeys' then
        exports.mm_carkeys:RemoveTempKeys(plate)
    elseif keysResource == 'MrNewbVehicleKeys' then
        exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
    elseif keysResource == 'mx_carkeys' then
        exports.mx_carkeys:removeVehicleKey(vehicle)
    elseif keysResource == 'qs-vehiclekeys' then
        exports['qs-vehiclekeys']:RemoveKeys(plate, GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)), true)
    elseif keysResource == 'Renewed-Vehiclekeys' then
        exports['Renewed-Vehiclekeys']:removeKey(plate)
    elseif keysResource == 'stasiek_vehiclekeys' then
        DecorSetInt(vehicle, 'owner', 0)
    elseif keysResource == 'tc_keys' then
        TriggerEvent('tc_keys:client:revokeAccess', plate)
    elseif keysResource == 't1ger_keys' then
        -- Resource does not support this feature.
    elseif keysResource == 'tgiann-hotwire' then
        -- Resource does not support this feature.
    elseif keysResource == 'ti_vehicleKeys' then
        exports.ti_vehicleKeys:addTemporaryVehicle(plate)
    elseif keysResource == 'vehicles_keys' then
        TriggerServerEvent('vehicles_keys:selfRemoveKeys', plate)
    elseif keysResource == 'wasabi_carlock' then
        exports.wasabi_carlock:RemoveKey(plate)
    elseif keysResource == 'xd_locksystem' then
        local success = pcall(function()
            exports.xd_locksystem:takePlayerKeys(plate) -- v1
        end)
        if not success then
            pcall(function()
                exports.xd_locksystem:SetVehicleKey(plate, true) -- v2
            end)
        end
    elseif keysResource == 'qbx_vehiclekeys' then
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate) -- Not been tested.
    elseif keysResource == 'qb-vehiclekeys' then
        TriggerEvent('qb-vehiclekeys:client:RemoveKeys', plate)
    elseif keysResource == 'other' then
        --- Implement other vehicle keys give method here.
    elseif keysResource == 'none' then

    end
end

RegisterNetEvent('cd_bridge:RemoveVehicleKeys', function(plate, vehicle)
    RemoveVehicleKeys(plate, vehicle)
end)



-- ┌──────────────────────────────────────────────────────────────────┐
-- │                    BACKWARDS COMPATIBILITY                       │
-- └──────────────────────────────────────────────────────────────────┘

RegisterNetEvent('vehiclekeys:client:SetOwner', function(plate)
    GiveVehicleKeys(plate, nil)
end)

RegisterNetEvent('qb-vehiclekeys:client:RemoveKeys', function(plate)
    RemoveVehicleKeys(plate, nil)
end)


RegisterNetEvent('qb-vehiclekeys:client:AddKeys', function(plate)
    GiveVehicleKeys(plate, nil)
end)
