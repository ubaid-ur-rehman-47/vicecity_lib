--- @return boolean | nil # Returns true if the player is on duty, false if off duty, or nil if no integration is available.
function GetCustomJobDuty()
    if Cfg.Duty == 'none' then return nil end

    if Cfg.Duty == 'origen_police' then
        return exports.origen_police:IsOnDuty()
    end

    return nil
end

AddEventHandler('jobs_creator:toggleDuty', function(state)
    local onDuty = (state == true or state == 1 or state == 'on')
    if JobData.on_duty == onDuty then return end

    TriggerEvent('cd_bridge:OnDutyChanged', {
        duty_changed = true,
        old = { name = JobData.name, on_duty = JobData.on_duty },
        new = { name = JobData.name, on_duty = onDuty }
    })

    JobData.on_duty = onDuty
    if LastJobData then LastJobData.on_duty = onDuty end
end)