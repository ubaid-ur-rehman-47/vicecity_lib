-- ┌──────────────────────────────────────────────────────────────────┐
-- │                    BACKWARDS COMPATIBILITY                       │
-- └──────────────────────────────────────────────────────────────────┘

AddEventHandler('qb-vehicleshop:client:buyShowroomVehicle', function(vehicle, plate)
    TriggerEvent('cd_garage:UpdateGarageType')
end)

AddEventHandler("jg-dealerships:client:purchase-vehicle:config", function(vehicle, plate, purchaseType, amount, paymentMethod, financed)
    TriggerEvent('cd_garage:UpdateGarageType')
end)

RegisterNetEvent("jg-dealerships:client:purchase-vehicle:config", function(vehicle, plate, purchaseType, amount, paymentMethod, financed)
    RegisterPersistentVehicle(vehicle, plate)
end)

RegisterNetEvent("jg-dealerships:client:start-test-drive:config", function(vehicle, plate)

end)

RegisterNetEvent("jg-dealerships:client:sell-vehicle:config", function(vehicle, plate)
    RemoveVehicleKeys(plate, vehicle)
    UnRegisterPersistentVehicle(vehicle, plate)
end)