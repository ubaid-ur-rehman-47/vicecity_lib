--- @return boolean # Returns true if the player is dead, false otherwise.
local function isPlayerDead()
    if GetResourceState('osp_ambulance') == 'started' then
        return exports.osp_ambulance:isDead() == true
    end

    return GetIsPlayerDeadFromFramework() == true
end

--- @return boolean # Returns true if the player is hand cuffed, false otherwise.
local function isPlayerCuffed()
    if GetResourceState('jobs_creator') == 'started' then
        return exports.jobs_creator:isPlayerHandcuffed() == true
    end

    if GetResourceState('lunar_jobscreator') == 'started' then
        return exports.lunar_jobscreator:isCuffed() == true
    end

    if GetResourceState('origen_police') == 'started' then
        return exports.origen_police:IsHandcuffed() == true
    end

    return GetIsPlayerCuffedFromFramework() == true
end

--- @return boolean # Returns true if the player is being dragged, false otherwise.
local function isPlayerBeingDragged()
    if GetResourceState('lunar_jobscreator') == 'started' then
        return exports.lunar_jobscreator:isDragged() == true
    end

    return false
end

--- @return boolean # Returns true if the player is dead, hand cuffed, or being dragged; false otherwise.
function IsPlayerDeadCuffedOrDragged()
    return isPlayerDead() or isPlayerCuffed() or isPlayerBeingDragged()
end