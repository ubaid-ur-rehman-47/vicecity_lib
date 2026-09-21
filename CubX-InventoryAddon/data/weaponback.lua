--  ____    _    _   _ _   _ 
-- |  _ \  / \  | \ | | | | |
-- | | | |/ _ \ |  \| | | | |
-- | |_| / ___ \| |\  | |_| |
-- |____/_/   \_\_| \_|\___/ 
--
--  fixed and cleaned by danu rodrigo / discord - akuma_xox

CubXWeaponBackConfig = {
    maxSlots = 4,
    bone = 24816, -- SKEL_Spine1
    detachOnEquip = true,
    
    slots = {
        [1] = { pos = vec3(0.14, -0.17, 0.0), rot = vec3(0.0, 0.0, 0.0) },
        [2] = { pos = vec3(0.14, 0.16, 0.0),  rot = vec3(0.0, 0.0, 0.0) },
        [3] = { pos = vec3(0.14, -0.21, 0.0), rot = vec3(0.0, 0.0, 0.0) },
        [4] = { pos = vec3(0.14, 0.20, 0.0),  rot = vec3(0.0, 0.0, 0.0) },
    },

    weapons = {
        ['WEAPON_ASSAULTRIFLE'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 150.0, 0.0) },
        ['WEAPON_CARBINERIFLE'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 150.0, 0.0) },
        ['WEAPON_SMG']          = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 150.0, 0.0) },
        
        default = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 0.0, 0.0) },

        ['WEAPON_BAT'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_BATTLEAXE'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_CROWBAR'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_FIREEXTINGUISHER'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_GOLFCLUB'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_HATCHET'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_HAZARDCAN'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_FERTILIZERCAN'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_MACHETE'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_NIGHTSTICK'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_PETROLCAN'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_POOLCUE'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_STONE_HATCHET'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_WRENCH'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
        ['WEAPON_CANDYCANE'] = { pos = vec3(0.0, 0.0, 0.0), rot = vec3(0.0, 92.5, 0.0) },
    },
}