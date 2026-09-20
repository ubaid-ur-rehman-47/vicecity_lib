--[[
    qb-garages client adapter — uses QBCore.Functions.TriggerCallback to
    deposit/list, and its own client event to take a vehicle out.
]]

local ALL_CLASSES = { 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22 }

local function currentVehicle()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    return veh ~= 0 and veh or nil
end

local function qbCore()
    if GetResourceState('qb-core') ~= 'started' then return nil end
    local ok, core = pcall(function() return exports['qb-core']:GetCoreObject() end)
    return ok and core or nil
end

local function qbAwait(core, name, ...)
    local p = promise.new()
    core.Functions.TriggerCallback(name, function(...) p:resolve(table.pack(...)) end, ...)
    local result = Citizen.Await(p)
    return table.unpack(result, 1, result.n)
end

ViceCityCreateClientGarageAdapter('qb-garages', 'qb-garages', {
    capabilities = { open = true, listVehicles = true, storeVehicle = true, retrieveVehicle = true },

    storeVehicle = function(self, vehicle, garageId)
        local core = qbCore()
        if not core then return false, { reason = 'missing_dependency', dependency = 'qb-core' } end
        vehicle = vehicle or currentVehicle()
        if not vehicle then return false, { reason = 'no_vehicle' } end
        local plate = core.Functions.GetPlate(vehicle)
        if not qbAwait(core, 'qb-garages:server:canDeposit', plate, 'public', garageId, 1) then
            return false, { reason = 'not_owned' }
        end
        TriggerServerEvent('qb-garages:server:UpdateOutsideVehicle', plate, 0)
        for seat = -1, 5 do
            local ped = GetPedInVehicleSeat(vehicle, seat)
            if ped ~= 0 then TaskLeaveVehicle(ped, vehicle, 0) end
        end
        Wait(1500)
        core.Functions.DeleteVehicle(vehicle)
        return true
    end,

    listVehicles = function(self, garageId)
        local core = qbCore()
        if not core then return false, { reason = 'missing_dependency', dependency = 'qb-core' } end
        local rows = qbAwait(core, 'qb-garages:server:GetGarageVehicles', garageId, 'public', ALL_CLASSES)
        return type(rows) == 'table' and rows or {}
    end,

    retrieveVehicle = function(self, vehicleId, garageId, spawnPoint)
        TriggerEvent('qb-garages:client:takeOutGarage', {
            garage = { spawnPoint = { spawnPoint } },
            plate = vehicleId,
            type = 'public',
        })
        return true
    end,

    open = function(self, garageId)
        if currentVehicle() then return self:storeVehicle(nil, garageId) end
        return true -- caller drives its own UI from ClientListVehicles()
    end,
})
