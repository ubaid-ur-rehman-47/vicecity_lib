--[[
    Keybind registration utility (client) — wraps RegisterKeyMapping, which
    requires a backing command to already exist.

    Global API:
      ViceCity.RegisterKeybind(name, description, handler, mapper, defaultKey)
]]

local registered = {}

function ViceCity.RegisterKeybind(name, description, handler, mapper, defaultKey)
    if registered[name] then return false, { reason = 'already_registered', command = name } end
    RegisterCommand(name, handler, false)
    RegisterKeyMapping(name, description, mapper or 'keyboard', defaultKey or '')
    registered[name] = true
    return true
end
