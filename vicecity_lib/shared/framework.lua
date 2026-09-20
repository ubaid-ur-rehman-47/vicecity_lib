ViceCity.Framework = ViceCity.Framework or {}

local function adapter()
    return ViceCity.FrameworkAdapter
end

local function call(name, ...)
    local provider = adapter()
    local method = provider and provider[name]
    if type(method) ~= 'function' then return nil end
    return method(provider, ...)
end

function ViceCity.Framework.GetName()
    return ViceCity.GetProvider('framework')
end

function ViceCity.Framework.GetCapabilities()
    local provider = adapter()
    return provider and provider.capabilities or {}
end

function ViceCity.Framework.GetRawObject()
    return call('getRawObject')
end

function ViceCity.Framework.IsLoaded()
    return call('isLoaded') == true
end

function ViceCity.Framework.GetPlayerData()
    return call('getPlayerData')
end

function ViceCity.Framework.GetIdentifier()
    return call('getIdentifier')
end

function ViceCity.Framework.GetNameForPlayer()
    return call('getName')
end

function ViceCity.Framework.GetCharacter()
    return call('getCharacter')
end

function ViceCity.Framework.GetJob()
    return call('getJob')
end

function ViceCity.Framework.GetGang()
    return call('getGang')
end

function ViceCity.Framework.GetAccounts()
    return call('getAccounts') or {}
end

function ViceCity.Framework.GetBalance(account)
    return call('getBalance', account) or 0
end

function ViceCity.Framework.GetMetadata()
    return call('getMetadata') or {}
end

function ViceCity.Framework.GetVehicleProperties(vehicle)
    return call('getVehicleProperties', vehicle)
end

function ViceCity.Framework.GetPlayer(source)
    return call('getPlayer', source)
end

function ViceCity.Framework.GetPlayers()
    return call('getPlayers') or {}
end

function ViceCity.Framework.GetPlayerByIdentifier(identifier)
    return call('getPlayerByIdentifier', identifier)
end

function ViceCity.Framework.AddMoney(source, account, amount)
    return call('addMoney', source, account, amount) == true
end

function ViceCity.Framework.RemoveMoney(source, account, amount)
    return call('removeMoney', source, account, amount) == true
end

function ViceCity.Framework.HasPermission(source, permission)
    return call('hasPermission', source, permission) == true
end

function ViceCity.Framework.GetRawPlayer(source)
    return call('getRawPlayer', source)
end

ViceCity.GetFramework = ViceCity.GetFramework or function()
    return ViceCity.Framework
end
