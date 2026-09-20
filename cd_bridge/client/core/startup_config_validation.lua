function GetMissingPreStartItems(resource)
    local cb = exports.cd_bridge:Callback('cd_bridge:GetMissingPreStartItems', resource)
    return cb or {}
end
exports('GetMissingPreStartItems', GetMissingPreStartItems)