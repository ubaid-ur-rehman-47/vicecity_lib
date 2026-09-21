local MALE_MODEL_HASH = joaat('mp_m_freemode_01')

local function genderKey(ped)
    return GetEntityModel(ped) == MALE_MODEL_HASH and 'm' or 'f'
end

function ViceCity.Appearance.GetDefaultComponent(ped, component)
    ped = ped or PlayerPedId()
    local defaults = ViceCity.AppearanceDefaults[genderKey(ped)]
    for name, id in pairs(ViceCity.AppearanceSlotComponents) do
        if id == component then
            return defaults[name]
        end
    end
    return nil
end

function ViceCity.Appearance.GetDefaultProp(ped, prop)
    ped = ped or PlayerPedId()
    local defaults = ViceCity.AppearanceDefaults[genderKey(ped)]
    for name, id in pairs(ViceCity.AppearanceSlotProps) do
        if id == prop then
            return defaults[name]
        end
    end
    return nil
end
