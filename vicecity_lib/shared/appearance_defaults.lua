-- Default ("naked"/bare) component and prop values per gender, used to
-- visually hide a clothing slot without changing the player's saved outfit.
ViceCity.AppearanceDefaults = {
    ['m'] = {
        undershirt = { drawable = 15, texture = 0 },
        torso      = { drawable = 15, texture = 0 },
        arms       = { drawable = 15, texture = 0 },
        mask       = { drawable = 0, texture = 0 },
        legs       = { drawable = 14, texture = 0 },
        shoes      = { drawable = 34, texture = 0 },
        bracelet   = { drawable = -1, texture = 0 },
        watch      = { drawable = -1, texture = 0 },
        glasses    = { drawable = -1, texture = 0 },
        ears       = { drawable = -1, texture = 0 },
        hat        = { drawable = -1, texture = 0 },
        necklace   = { drawable = 0, texture = 0 },
        bag        = { drawable = 0, texture = 0 },
        armor      = { drawable = 0, texture = 0 },
        decals     = { drawable = 0, texture = 0 },
    },
    ['f'] = {
        undershirt = { drawable = 15, texture = 0 },
        torso      = { drawable = 15, texture = 0 },
        arms       = { drawable = 15, texture = 0 },
        mask       = { drawable = 0, texture = 0 },
        legs       = { drawable = 15, texture = 0 },
        shoes      = { drawable = 35, texture = 0 },
        bracelet   = { drawable = -1, texture = 0 },
        watch      = { drawable = -1, texture = 0 },
        glasses    = { drawable = -1, texture = 0 },
        ears       = { drawable = -1, texture = 0 },
        hat        = { drawable = -1, texture = 0 },
        necklace   = { drawable = 0, texture = 0 },
        bag        = { drawable = 0, texture = 0 },
        armor      = { drawable = 0, texture = 0 },
        decals     = { drawable = 0, texture = 0 },
    },
}

-- Maps clothing slot keys (as used by inventory/wardrobe UIs) to component/prop ids.
ViceCity.AppearanceSlotComponents = {
    mask = 1,
    arms = 3,
    legs = 4,
    bag = 5,
    shoes = 6,
    necklace = 7,
    undershirt = 8,
    armor = 9,
    decals = 10,
    torso = 11,
}

ViceCity.AppearanceSlotProps = {
    hat = 0,
    glasses = 1,
    ears = 2,
    watch = 6,
    bracelet = 7,
}
