--[[
    Command registration utility (shared) — thin wrapper over RegisterCommand
    with duplicate-registration protection and an optional chat suggestion.

    Global API:
      ViceCity.RegisterCommand(name, handler, options)
]]

local registered = {}

-- options: { restricted = bool, help = string, arguments = {{name, help}}, suggest = bool }
function ViceCity.RegisterCommand(name, handler, options)
    options = options or {}
    if registered[name] then return false, { reason = 'already_registered', command = name } end
    RegisterCommand(name, handler, options.restricted or false)
    registered[name] = true
    if options.suggest ~= false and not IsDuplicityVersion() then
        TriggerEvent('chat:addSuggestion', '/' .. name, options.help or '', options.arguments)
    end
    return true
end
