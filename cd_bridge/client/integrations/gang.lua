--- @return table | nil # A table containing gang information (name, label, grade) or nil if no gang is detected or integration is not available.
function GetCustomGang()
    if Cfg.Gang == 'none' then return nil end

    return exports.cd_bridge:Callback('cd_bridge:GetCustomGang')
end