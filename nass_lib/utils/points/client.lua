local points = {}
local nearbyPoints = {}
local nearbyCount = 0
local closestPoint
local tick
local createdPoints = {}

local function removePoint(self)
    if self.onRemove then
        self:onRemove()
    end
    if closestPoint and closestPoint.id == self.id then
        closestPoint = nil
    end
    points[self.id] = nil
end

local function toVector(coords)
    local _type = type(coords)
    if _type ~= 'vector3' then
        if _type == 'table' or _type == 'vector4' then
            return vec3(coords[1] or coords.x, coords[2] or coords.y, coords[3] or coords.z)
        end
        error(("expected type 'vector3' or 'table' (received %s)"):format(_type))
    end
    return coords
end

nass.points = {
    new = function(...)
        local args = { ... }
        local id = #points + 1
        local self

        if type(args[1]) == 'table' then
            self = args[1]
            self.id = id
            self.remove = removePoint
        else
            self = {
                id = id,
                coords = args[1],
                remove = removePoint,
            }
        end

        self.coords = toVector(self.coords)
        self.distance = self.distance or args[2]

        if args[3] then
            for k, v in pairs(args[3]) do
                self[k] = v
            end
        end

        self.resource = self.resource or GetInvokingResource()

        points[id] = self
        if not createdPoints[self.resource] then
            createdPoints[self.resource] = {}
        end
        table.insert(createdPoints[self.resource], self)
        return self
    end,

    getAllPoints = function() return points end,
    getNearbyPoints = function() return nearbyPoints end,
    getClosestPoint = function() return closestPoint end,
}

local function updateNearbyPoints()
    local coords = GetEntityCoords(PlayerPedId())

    if closestPoint and #(coords - closestPoint.coords) > closestPoint.distance then
        closestPoint.isClosest = nil
        closestPoint = nil
    end

    nearbyCount = 0
    for _, point in pairs(points) do
        local distance = #(coords - point.coords)
        point.currentDistance = distance

        if distance <= point.distance then
            if not closestPoint or distance < closestPoint.currentDistance then
                if closestPoint then
                    closestPoint.isClosest = nil
                end
                point.isClosest = true
                closestPoint = point
            end

            if point.nearby then
                nearbyCount = nearbyCount + 1
                nearbyPoints[nearbyCount] = point
            end

            if point.onEnter and not point.inside then
                point.inside = true
                point:onEnter()
            elseif not point.inside then
                point.inside = true
            end
        else
            if point.inside then
                if point.onExit then 
                    point:onExit() 
                end
                point.inside = nil
            end
            point.currentDistance = nil
        end
    end
end

CreateThread(function()
    while true do
        updateNearbyPoints()

        if nearbyCount > 0 and not tick then
            tick = SetInterval(function()
                for i = 1, nearbyCount do
                    local point = nearbyPoints[i]
                    if point and point.nearby then
                        pcall(point.nearby, point)
                    end
                end
            end, 0)
        elseif nearbyCount == 0 and tick then
            tick = ClearInterval(tick)
        end

        Wait(300)
    end
end)

AddEventHandler('onResourceStop', function(resourceName)
    if createdPoints[resourceName] then 
		for k, v in pairs(createdPoints[resourceName]) do
			removePoint(v)
		end
        createdPoints[resourceName] = {}
	end
end)