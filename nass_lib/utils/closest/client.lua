function nass.getClosestVehicle(coords, exclude)
    local allVehicles = GetGamePool('CVehicle')
    local closestVeh = nil
    local vehDist = 50
    local vec3Coords = vector3(coords.x, coords.y, coords.z)

    for k, v in pairs(allVehicles) do
        local distance = #(vec3Coords - GetEntityCoords(v))

        if distance < vehDist then
            if exclude then
                if type(exclude) == "number" then
                    if v ~= exclude then
                        closestVeh = v 
                        vehDist = distance
                    end
                elseif type(exclude) == "table" then
                    if exclude[v] == nil then
                        closestVeh = v 
                        vehDist = distance
                    end
                end
                
            else
                closestVeh = v 
                vehDist = distance
            end   
        end
    end
    return closestVeh, vehDist
end

function nass.getClosestPlayers(coords, distance)
    local nearbyPlayers = {}
    
    if not coords then
        coords = GetEntityCoords(PlayerPedId())
    end

    local distance = distance or 3.0
    for _, v in pairs(GetActivePlayers()) do
        local target = GetPlayerPed(v)
        local targetdistance = #(GetEntityCoords(target) - coords)
        if targetdistance <= distance then
            nearbyPlayers[#nearbyPlayers + 1] = {player = v, id = GetPlayerServerId(v)}
        end
    end
    
    return nearbyPlayers
end