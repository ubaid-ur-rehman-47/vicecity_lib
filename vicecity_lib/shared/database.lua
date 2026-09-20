--[[
    Database layer (shared) — minimal parameterized-query contract used only
    by explicit SQL fallbacks (e.g. vehicle persistence). vicecity_lib never
    assumes a database exists; this stays 'none' unless a query provider is
    installed and registers itself.

    Global API:
      ViceCity.Database.*        parameterized query helpers
      ViceCity.DatabaseAdapter   registration point for custom providers
]]

ViceCity.Database = ViceCity.Database or {}

function ViceCity.Database.GetProvider()
    return ViceCity.GetProvider('database') or 'none'
end

function ViceCity.Database.IsAvailable()
    return ViceCity.Database.GetProvider() ~= 'none'
end

function ViceCity.Database.Query(query, params)
    local provider = ViceCity.DatabaseAdapter
    if not provider or type(provider.query) ~= 'function' then
        return false, { reason = 'unsupported', operation = 'query', provider = ViceCity.Database.GetProvider() }
    end
    return provider:query(query, params)
end

function ViceCity.Database.Execute(query, params)
    local provider = ViceCity.DatabaseAdapter
    if not provider or type(provider.execute) ~= 'function' then
        return false, { reason = 'unsupported', operation = 'execute', provider = ViceCity.Database.GetProvider() }
    end
    return provider:execute(query, params)
end

function ViceCity.Database.Insert(query, params)
    local provider = ViceCity.DatabaseAdapter
    if not provider or type(provider.insert) ~= 'function' then
        return false, { reason = 'unsupported', operation = 'insert', provider = ViceCity.Database.GetProvider() }
    end
    return provider:insert(query, params)
end
