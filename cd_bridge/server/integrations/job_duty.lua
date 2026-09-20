--- @param source number The player's server ID.
--- @return boolean | nil # Returns true if the player is on duty, false if off duty, or nil if no integration is available.
function GetCustomJobDuty(source)
    if Cfg.Duty == 'none' then return nil end
    if Cfg.Duty == 'origen_police' and Cfg.Framework == 'esx' then return nil end

    if Cfg.Duty == 'jobs_creator' then
        return exports.jobs_creator:isPlayerOnDuty(source)

    elseif Cfg.Duty == 'origen_police' then
        local job = GetJobName(source)
        local players = exports.origen_police:GetPlayersInDuty(job)
        for _, playerSrc in pairs(players) do
            if playerSrc == source then return true end
        end
        return false
    end

    return nil
end