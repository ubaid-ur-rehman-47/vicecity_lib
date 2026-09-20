nass = {}
function nass.getCoordsInDirection(current_position, heading, distance)
    local heading_radians = math.rad(heading)
    
    local direction = {
        math.cos(heading_radians),
        math.sin(heading_radians),
        0
    }

    local scaled_direction = {
        direction[1] * distance,
        direction[2] * distance,
        direction[3] * distance
    }
    
    local new_position = vec3(current_position.x + scaled_direction[1], current_position.y + scaled_direction[2], current_position.z + scaled_direction[3])

    return new_position
end

--Terribly broken. Used for nass_paintball animations
function nass.getDirectionCoords(x, y, z, w, distance, direction)
    local yaw = w
    if direction == 'left' then
        yaw = yaw + 90
    elseif direction == 'right' then
        yaw = yaw - 90
    elseif direction == 'front' then
        yaw = yaw - 180
    end

    local yaw_radians = math.rad(yaw)
    local delta_x = -math.sin(yaw_radians) * distance
    local delta_y = -math.cos(yaw_radians) * distance
    local new_x = x + delta_x
    local new_y = y + delta_y
    
    return new_x, new_y, z, w
end

function nass.deepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[nass.deepCopy(orig_key)] = nass.deepCopy(orig_value)
        end
        setmetatable(copy, nass.deepCopy(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

function nass.exportHandler(resourcename, exportName, func)
    AddEventHandler(('__cfx_export_'..resourcename..'_%s'):format(exportName), function(setCB)
        setCB(func)
    end)
end

function nass.upper(str)
    return (str:gsub("^%l", string.upper))
end

function nass.getTableLength(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function nass.keys(tbl)
    local keys = {}
    for k in pairs(tbl) do
        table.insert(keys, k)
    end
    return keys
end

function nass.values(tbl)
    local values = {}
    for _, v in pairs(tbl) do
        table.insert(values, v)
    end
    return values
end

exports('getObject', function()
    return nass
end)