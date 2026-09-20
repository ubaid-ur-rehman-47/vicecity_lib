--[[
    qbx_garages client adapter — uses ox_lib callbacks to park/list/spawn.
]]

local function currentVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    return veh ~= 0 and veh or nil
end

ViceCityCreateClientGarageAdapter('qbx_garages', 'qbx_garages', {
    capabilities = { open = true, listVehicles = true, storeVehicle = true, retrieveVehicle = true },

    storeVehicle = function(self, vehicle, garageId)
        if not lib or not lib.callback then
            return false, { reason = 'missing_dependency', dependency = 'ox_lib' }
        end
        vehicle = vehicle or currentVehicle()
        if not vehicle then return false, { reason = 'no_vehicle' } end
        local netId = NetworkGetNetworkIdFromEntity(vehicle)
        local parkable = lib.callback.await('qbx_garages:server:isParkable', false, garageId, netId)
        if not parkable then return false, { reason = 'not_owned' } end
        local props = lib.getVehicleProperties and lib.getVehicleProperties(vehicle) or {}
        lib.callback.await('qbx_garages:server:parkVehicle', false, netId, props, garageId)
        return true
    end,

    listVehicles = function(self, garageId)
        if not lib or not lib.callback then
            return false, { reason = 'missing_dependency', dependency = 'ox_lib' }
        end
        local vehicles = lib.callback.await('qbx_garages:server:getGarageVehicles', false, garageId)
        return type(vehicles) == 'table' and vehicles or {}
    end,

    retrieveVehicle = function(self, vehicleId, garageId, accessIndex)
        if not lib or not lib.callback then
            return false, { reason = 'missing_dependency', dependency = 'ox_lib' }
        end
        return lib.callback.await('qbx_garages:server:spawnVehicle', false, vehicleId, garageId, accessIndex or 1)
    end,

    open = function(self, garageId)
        if currentVehicle() then return self:storeVehicle(nil, garageId) end
        return true -- caller drives its own UI from ClientListVehicles()
    end,
})
