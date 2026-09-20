ViceCity.Appearance = ViceCity.Appearance or {}
ViceCity.Wardrobe = ViceCity.Wardrobe or {}

local function provider()
    return ViceCity.AppearanceAdapter
end

local function call(name, ...)
    local adapter = provider()
    local method = adapter and adapter[name]
    if type(method) ~= 'function' then
        return false, { reason = 'unsupported', operation = name, provider = ViceCity.GetProvider('appearance') }
    end
    local ok, first, second = pcall(method, adapter, ...)
    if not ok then
        return false, { reason = 'provider_error', operation = name, error = tostring(first) }
    end
    return first, second
end

function ViceCity.Appearance.GetProvider()
    return ViceCity.GetProvider('appearance')
end

function ViceCity.Appearance.GetCapabilities()
    local adapter = provider()
    return adapter and adapter.capabilities or {}
end

function ViceCity.Appearance.Get(ped)
    return call('get', ped)
end

function ViceCity.Appearance.Set(ped, appearance)
    return call('set', ped, appearance)
end

function ViceCity.Appearance.GetRaw(ped)
    return call('getRaw', ped)
end

function ViceCity.Appearance.GetComponent(ped, component)
    return call('getComponent', ped, component)
end

function ViceCity.Appearance.SetComponent(ped, component, drawable, texture, palette)
    return call('setComponent', ped, component, drawable, texture, palette)
end

function ViceCity.Appearance.GetProp(ped, prop)
    return call('getProp', ped, prop)
end

function ViceCity.Appearance.SetProp(ped, prop, drawable, texture)
    return call('setProp', ped, prop, drawable, texture)
end

function ViceCity.Appearance.GetHair(ped)
    return call('getHair', ped)
end

function ViceCity.Appearance.SetHair(ped, hair)
    return call('setHair', ped, hair)
end

function ViceCity.Appearance.SetModel(model, appearance)
    return call('setModel', model, appearance)
end

function ViceCity.Appearance.Save(appearance)
    return call('save', appearance)
end

function ViceCity.Appearance.Load()
    return call('load')
end

function ViceCity.Wardrobe.Open(options)
    return call('openWardrobe', options)
end

function ViceCity.Wardrobe.Save(name, appearance)
    return call('saveOutfit', name, appearance)
end

function ViceCity.Wardrobe.Load(name)
    return call('loadOutfit', name)
end

function ViceCity.Wardrobe.Delete(name)
    return call('deleteOutfit', name)
end

function ViceCity.Wardrobe.List()
    return call('getOutfits')
end

GetAppearance = ViceCity.Appearance.Get
SetAppearance = ViceCity.Appearance.Set
OpenWardrobe = ViceCity.Wardrobe.Open
GetAppearanceProvider = ViceCity.Appearance.GetProvider
GetAppearanceCapabilities = ViceCity.Appearance.GetCapabilities
