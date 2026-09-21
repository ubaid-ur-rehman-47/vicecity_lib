--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

local defaultSections = {
    clothing = false,
    character = false,
    hud = false
}

local defaultAccentColor = {
    r = 32,
    g = 201,
    b = 151
}

local defaultCustomization = {
    enabled = true,
    accentColor = true,
    hudStyle = true,
    weightStyle = true,
    imageSize = true,
    visibility = true,
    weaponAimAnim = true,
    weaponEquipAnim = true
}

function GetInventorySections()
    if type(CubXInventoryConfig) == "table" then
        if type(CubXInventoryConfig.sections) == "table" then
            local sections = {}
            sections.clothing = CubXInventoryConfig.sections.clothing == true
            sections.character = CubXInventoryConfig.sections.character == true
            sections.hud = CubXInventoryConfig.sections.hud == true
            return sections
        end
    end
    
    return {
        clothing = false,
        character = false,
        hud = false
    }
end

function ClampColorValue(val)
    local num = tonumber(val) or val
    if not num then
        num = 0
    end
    if num < 0 then
        return 0
    end
    if num > 255 then
        return 255
    end
    return math.floor(num)
end

function GetDefaultAccentColor()
    local accentConfig = nil
    if type(CubXInventoryConfig) == "table" then
        if CubXInventoryConfig.accentColor then
            accentConfig = CubXInventoryConfig.accentColor
        end
    end
    
    local r, g, b
    if type(accentConfig) == "table" then
        r = ClampColorValue(accentConfig.r or accentConfig[1])
        g = ClampColorValue(accentConfig.g or accentConfig[2])
        b = ClampColorValue(accentConfig.b or accentConfig[3])
    else
        r = defaultAccentColor.r
        g = defaultAccentColor.g
        b = defaultAccentColor.b
    end
    
    local result = {
        r = r,
        g = g,
        b = b,
        hex = string.format("#%02X%02X%02X", r, g, b)
    }
    
    return result
end

function GetInventoryCustomization()
    local customConfig = nil
    if type(CubXInventoryConfig) == "table" then
        if CubXInventoryConfig.customization then
            customConfig = CubXInventoryConfig.customization
        end
    end
    
    local result = {}
    for key, value in pairs(defaultCustomization) do
        if type(customConfig) == "table" then
            if customConfig[key] ~= nil then
                result[key] = customConfig[key] == true
            else
                result[key] = value
            end
        else
            result[key] = value
        end
    end
    
    return result
end

exports("getInventoryConfig", function()
    return CubXInventoryConfig
end)

exports("getInventorySections", function()
    return GetInventorySections()
end)

exports("getInventoryCustomization", function()
    return GetInventoryCustomization()
end)

exports("getDefaultAccentColor", function()
    return GetDefaultAccentColor()
end)

CreateThread(function()
    local sections = GetInventorySections()
    local accentColor = GetDefaultAccentColor()
    print(string.format("[CubX-InventoryAddon] sections loaded -> clothing=%s character=%s hud=%s | accent=%s", tostring(sections.clothing), tostring(sections.character), tostring(sections.hud), accentColor.hex))
end)