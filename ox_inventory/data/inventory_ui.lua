-- Local cosmetic settings for the inventory NUI (character panel, hud
-- style, accent color). Previously sourced from CubX-InventoryAddon.
return {
    sections = {
        clothing = true,
        character = true,
        hud = true,
    },
    customization = {
        enabled = true,
        accentColor = true,
        hudStyle = true,
        weightStyle = true,
        imageSize = true,
        visibility = true,
        weaponAimAnim = true,
        weaponEquipAnim = true,
    },
    defaultAccentColor = { r = 32, g = 201, b = 151, hex = '#20C997' },
}
